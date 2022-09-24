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

      final body = jsonEncode({
        'name': userName,
      });

      final result = await post(
        Uri.http('0.0.0.0:8000', 'user'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      Map<String, dynamic> data = jsonDecode(result.body);

      User user = User(
        id: data['id'],
        name: data['name'],
      );
      
      return user;
    } catch (e) {
      return null;
    }
  }
}
