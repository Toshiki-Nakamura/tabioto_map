import 'dart:convert';

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
}
