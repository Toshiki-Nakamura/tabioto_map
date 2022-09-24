import 'dart:convert';

import 'package:gmaps/repository/place.dart';
import 'package:gmaps/repository/sound.dart';
import 'package:http/http.dart';

class Tabioto {
  int? id;
  String? name;
  double? lon; //経度
  double? lat; //緯度

  Tabioto({
    this.id,
    this.name,
    this.lon,
    this.lat,
  });

  static Future<List<Tabioto>?> getTabiotoList(double latitude,
      double longitude) async {
    try {
      print("request start get tabioto list");

      String uri =
          'http://0.0.0.0:8000/tabioto?latitude=$latitude&longitude=$longitude';

      final result = await get(Uri.parse(uri));

      var data = json.decode(utf8.decode(result.bodyBytes));

      List<Tabioto> tabiotoList = [];

      for (var ele in data) {
        Tabioto tabioto = Tabioto(
          id: ele['id'],
          name: ele['name'],
          lon: ele['longitude'],
          lat: ele['latitude'],
        );

        tabiotoList.add(tabioto);
      }

      return tabiotoList;
    } catch (e) {
      return null;
    }
  }

  static Future<TabiotoDetail?> getByID(int placeId) async {
    try {
      print("request start get by tabioto id");

      String uri = 'http://0.0.0.0:8000/tabioto/$placeId';

      final result = await get(Uri.parse(uri));

      Map<String, dynamic> data = jsonDecode(result.body);

      Place place = Place(
          id: data['place']['id'],
          name: data['place']['name'],
          lat: data['place']['latitude'],
          lon: data['place']['longitude']
      );
      
      List<Sound> soundList = [];
      for (var ele in data['sound_list']) {
        Sound sound = Sound(title: ele['name'], url: ele['url']);

        soundList.add(sound);
      }

      return TabiotoDetail(place: place, soundList: soundList, placeCount: data['place_Count']);
    } catch (e) {
      return null;
    }
  }
}

class TabiotoDetail {
  Place? place;
  List<Sound>? soundList;
  int? placeCount;

  TabiotoDetail({
    this.place,
    this.soundList,
    this.placeCount,
  });
}
