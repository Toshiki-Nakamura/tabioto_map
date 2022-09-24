import 'dart:convert';

import 'package:http/http.dart';

class User {
  int? id;
  String? name;

  User({
    this.id,
    this.name,
  });

  static Future<User?> login(String userName) async {
    try {
      print("request start");
      final result = await post(Uri.http('0.0.0.0:8000', 'user'),
          body: {"name": userName}
      );

      Map<String, dynamic> data = jsonDecode(result.body);

      User user = User(
        id: data['id'],
        // TODO: レスポンスから表示する
        name: userName,
      );

      return user;
    } catch (e) {
      return null;
    }
  }
}