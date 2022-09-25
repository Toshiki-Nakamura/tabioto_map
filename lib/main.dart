import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gmaps/repository/tabioto.dart';
import 'package:gmaps/repository/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'provider/data.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps Demo',
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<Data>(
            create: (context) => Data(),
            child: const MapSample(),
          ),
        ],
        child: const MapSample(),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {

  late AudioPlayer _player;
  double _currentSliderValue = 1.0;
  bool _changeAudioSource = false;
  String _stateSource = '♪';
  bool _isPlayingSong = false;
  //gmap
  Position? currentPosition;
  late GoogleMapController _controller;
  late StreamSubscription<Position> positionStream;
  //初期位置
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(34.9880403, 135.7598385),
    zoom: 14,
  );

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );

  Set<Marker> markers_ = {};
  Map<LatLng, int?> cntMap = {};

  Future<void>? initApi;

  Future<void> setApi() async {
    List<Tabioto>? tabi = await Tabioto.getTabiotoList(34.9880403, 135.7598385);
    // print(tabi?[0].id ?? -1);
    // TabiotoDetail? api = await Tabioto.getByID(tabi![0].id!);
    // print(api?.placeCount);
    // cntMap[const LatLng(34.9880403, 135.7598385)] = api!.placeCount;

    await Future.forEach(tabi!, (elm) async {
      TabiotoDetail? api = await Tabioto.getByID(elm.id!);
      print(elm.id ?? -1);
      print(elm.lat!);
      print(elm.lon!);
      cntMap[LatLng(elm.lon!, elm.lat!)] = api!.placeCount;
      markers_.add(_createMarker(LatLng(elm.lon!, elm.lat!), LatLng(elm.lon!, elm.lat!).toString()));
    });

    // markers_.add(_createMarker(LatLng(elm.lat!, elm.lon!), LatLng(elm.lat!, elm.lon!).toString()));
    

    // tabi = await Tabioto.getTabiotoList(34.99693, 135.749815);
    // print(tabi?[0].id ?? -1);
    // api = await Tabioto.getByID(tabi![0].id!);
    // print(api?.placeCount);
    // cntMap[const LatLng(34.99693, 135.749815)] = api!.placeCount;

    // tabi = await Tabioto.getTabiotoList(34.994109, 135.756845);
    // print(tabi?[0].id ?? -1);
    // api = await Tabioto.getByID(tabi![0].id!);
    // print(api?.placeCount);
    // cntMap[const LatLng(34.994109, 135.756845)] = api!.placeCount;

    // markers_.add(_createMarker(const LatLng(34.992958, 135.765679), const LatLng(34.992958, 135.765679).toString()));
    // markers_.add(_createMarker(const LatLng(34.99693, 135.749815), const LatLng(34.99693, 135.749815).toString()));
    // markers_.add(_createMarker(const LatLng(34.994109, 135.756845), const LatLng(34.99693, 135.749815).toString()));
  }

  @override
  void initState() {
    super.initState();

    //位置情報が許可されていない時に許可をリクエストする
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied){
        await Geolocator.requestPermission();
      }
    });

    //現在位置を更新し続ける
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      currentPosition = position;
    });


    initApi = setApi();

    _setupSession();

    _player.playbackEventStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.idle:
          print('オーディオファイルをロードしていないよ');
          break;
        case ProcessingState.loading:
          print('オーディオファイルをロード中だよ');
          break;
        case ProcessingState.buffering:
          print('バッファリング(読み込み)中だよ');
          break;
        case ProcessingState.ready:
          print('再生できるよ');
          break;
        case ProcessingState.completed:
          print('再生終了したよ');
          break;
        default:
          print(event.processingState);
          break;
      }
    }
    );

    // markers_.add(_createMarker(const LatLng(34.992958, 135.765679), const LatLng(34.992958, 135.765679).toString()));
    // markers_.add(_createMarker(const LatLng(34.99693, 135.749815), const LatLng(34.99693, 135.749815).toString()));
    // markers_.add(_createMarker(const LatLng(34.994109, 135.756845), const LatLng(34.99693, 135.749815).toString()));
  }


  //mp3
  Future<void> _setupSession() async {
    _player = AudioPlayer();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    await _loadAudioFile();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _takeTurns() {
    late String _changeStateText;
    _changeAudioSource = _changeAudioSource ? false : true; // 真偽値を反転

    _player.stop();
    _loadAudioFile().then((_) {
      if (_changeAudioSource) {
        _changeStateText = '♬';
      } else {
        _changeStateText = '♪';
      }
      setState(() {
        _stateSource = _changeStateText;
      });
    });
  }

  callModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(15)),
      ),
      // backgroundColor: Colors.transparent,
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
        padding: EdgeInsets.all(20),
          height: 750,
          width: double.infinity,
          // color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10
                ),
                TextField(
                  controller: TextEditingController(text:"どんなタビノ音？"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(20),
                  )
                ),
                for (var i = 0; i < 20; i++)
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Card(
                      elevation:0,
                      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
                      child: InkWell(
                        onTap:() async {
                          if(_isPlayingSong == true){
                            _turnToFalse();
                          }else{
                            _takeTurns();
                            await _playSoundFile();
                          }
                        },
                        child: Padding(
                          padding:EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Card(shape: CircleBorder(),child: Icon(Icons.person,size: 50,)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("ナナシ",textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold),),
                                      Text("1999/08/26",textAlign: TextAlign.left,)
                                    ],
                                  ),

                                ],
                              ),
                              Container(

                                child: Card(
                                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
                                  child: Padding(
                                    padding:EdgeInsets.all(30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            border: Border.all(color:Colors.white,width:2),
                                            borderRadius: BorderRadius.circular(8),
                                            color: Color.fromRGBO(242, 242, 242, 1),

                                      ),
                                            child: Icon(Icons.headphones)
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("タイトル",textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text("#ハッシュタグ",textAlign: TextAlign.left,),
                                            // IconButton(
                                            //   icon: const Icon(Icons.play_arrow),
                                            //   onPressed: () async =>
                                            //       await _playSoundFile(),
                                            // ),
                                            // IconButton(
                                            //   icon: const Icon(Icons.pause),
                                            //   onPressed: () async =>
                                            //   await _player.pause(),
                                            // )
                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Marker _createMarker(LatLng latlang, String idName) {
    return Marker(
      markerId: MarkerId(idName),
      position: latlang,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: '投稿件数: ${cntMap[latlang]}',
        onTap: () {
          callModal();
          // List<Tabioto>? tabi = await Tabioto.getTabiotoList(34.992958, 135.765679);
          // print(tabi?[0].id ?? -1);
          // TabiotoDetail? api = await Tabioto.getByID(0);
          // print(api?.placeCount);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Data data = Provider.of<Data>(context);
    return FutureBuilder(
      future: initApi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true, //現在位置をマップ上に表示
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            onTap: (LatLng latLang) {
              setState(() {
                markers_.add(_createMarker(latLang, latLang.toString()));
              });
            },
            markers: markers_,
          );
        }
        return const CircularProgressIndicator();
      }
    );
  }

  Future<void> _playSoundFile() async {
    // 再生終了状態の場合、新たなオーディオファイルを定義し再生できる状態にする
    if (_player.processingState == ProcessingState.completed) {
      await _loadAudioFile();
    }

    await _player.setSpeed(_currentSliderValue); // 再生速度を指定
    await _player.play();
    _isPlayingSong = true;
  }
  _turnToFalse(){
  _isPlayingSong = false;
  }

  Future<void> _loadAudioFile() async {
    try {
      if (_changeAudioSource) {
        await _player.setUrl(
            'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3'); // ストリーミング
      } else {
        await _player.setAsset('assets/audio/cute.mp3'); // アセット(ローカル)のファイル
      }
    } catch (e) {
      print(e);
    }
  }
}
