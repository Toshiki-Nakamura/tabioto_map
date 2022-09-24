import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gmaps/repository/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'provider/data.dart';

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

    markers_.add(_createMarker(const LatLng(34.992958, 135.765679), const LatLng(34.992958, 135.765679).toString()));
    markers_.add(_createMarker(const LatLng(34.99693, 135.749815), const LatLng(34.99693, 135.749815).toString()));
    markers_.add(_createMarker(const LatLng(34.994109, 135.756845), const LatLng(34.99693, 135.749815).toString()));
  }

  callModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
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
                  Card(
                    child: ListTile(
                      title: Text('item $i'),
                    ),
                  )
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
        title: '投稿件数: ',
        onTap: () {
          callModal();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Data data = Provider.of<Data>(context);
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
}
