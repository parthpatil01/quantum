import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:quantum_it/user_modal.dart';

class ApiService {
  Future<List<UserModel>?> getUsers() async {
    try {
      var url = Uri.parse('https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=e5f2d5fa09274f299a17437dd81aa901');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<UserModel> _model = userModelFromJson(response.body);
        return _model;
      }
    } catch (e) {
      log(e.toString());
    }
  }
}