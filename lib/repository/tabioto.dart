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

  static Future<List<Tabioto>?> getTabiotoList(
      double latitude, double longitude) async {
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

  static Future<List<Tabioto>?> getUserTabiotoList(
      int userId, double latitude, double longitude) async {
    try {
      print("request start get user tabioto list");

      String uri =
          'http://0.0.0.0:8000/tabioto/user/$userId?latitude=$latitude&longitude=$longitude';

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

      Map<String, dynamic> data = json
          .decode(utf8.decode(result.bodyBytes));

      Place place = Place(
          id: data['place']['id'],
          name: data['place']['name'],
          lat: data['place']['latitude'],
          lon: data['place']['longitude']);

      List<Sound> soundList = [];
      for (var ele in data['sound_list']) {
        Sound sound = Sound(title: ele['name'], url: ele['url']);

        soundList.add(sound);
      }
      // print('data: ${data['place_count']}');
      return TabiotoDetail(
          place: place, soundList: soundList, placeCount: data['place_count']);
    } catch (e) {
      return null;
    }
  }

  static Future<Sound?> create(int userId, String title, String content) async {
    try {
      print("request start post tabioto");

      final body = jsonEncode({
        'user_id': userId,
        'title': title,
        'content': content,
      });

      final result = await post(
        Uri.http('0.0.0.0:8000', 'tabioto'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );



      Map<String, dynamic> data = json
          .decode(utf8.decode(result.bodyBytes));
      
      return Sound(title: data['title'], url: data['sound_url']);
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
