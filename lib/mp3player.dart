import 'dart:async';
// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
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
  String _stateSource = 'アセットを再生';

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

  @override
  void initState() {
    super.initState();

    //位置情報が許可されていない時に許可をリクエストする
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    });

    //現在位置を更新し続ける
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      currentPosition = position;
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }

  //mp3
  void _takeTurns() {
    late String _changeStateText;
    _changeAudioSource = _changeAudioSource ? false : true; // 真偽値を反転

    _player.stop();
    _loadAudioFile().then((_) {
      if (_changeAudioSource) {
        _changeStateText = 'ストリーミング再生';
      } else {
        _changeStateText = 'アセットを再生';
      }
      setState(() {
        _stateSource = _changeStateText;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            height: 600,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true, //現在位置をマップ上に表示
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
            ),
          ),
          //ボタンにモーダル表示を埋め込んでる(ピンに変えたい)
          Center(
            child: ElevatedButton(
              onPressed: () {
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
                      height: 750,
                      width: double.infinity,
                      // color: Colors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var i = 0; i < 5; i++)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(_stateSource),
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () async =>
                                        await _playSoundFile(),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.pause),
                                    onPressed: () async =>
                                        await _player.pause(),
                                  )
                                ],
                              ),
                            // Card(
                            //   child: ListTile(
                            //     title: Text('item $i'),
                            //   ),
                            // )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text('button'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takeTurns,
        tooltip: 'Increment',
        child: const Icon(Icons.autorenew),
      ),
    );
  }

  Future<void> _playSoundFile() async {
    // 再生終了状態の場合、新たなオーディオファイルを定義し再生できる状態にする
    if (_player.processingState == ProcessingState.completed) {
      await _loadAudioFile();
    }

    await _player.setSpeed(_currentSliderValue); // 再生速度を指定
    await _player.play();
  }

  Future<void> _loadAudioFile() async {
    try {
      if (_changeAudioSource) {
        await _player.setUrl(
            'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3'); // ストリーミング
      } else {
        print('assets/audio/cute.mp3'); // アセット(ローカル)のファイル
      }
    } catch (e) {
      print(e);
    }
  }
}
