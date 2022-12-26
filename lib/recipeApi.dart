import 'dart:convert';
import 'package:http/http.dart' as http;
import './recipe.dart';

class RecipeApi {
  //Get all User Details
  Future<List<Recipe>?> getAllrecipes() async {
    var client = http.Client();
    //http://127.0.0.1:5000/user
    var uri = Uri.parse("http://10.0.2.2:5000/recipe");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return recipeFromJson(json);
    }
  }

  //Add New User
  Future<Food> addFood(String name) async {
    var client = http.Client();
    var uri = Uri.parse("http://10.0.2.2:5000/recipe");
    final http.Response response = await client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{'name': name}),
    );
    if (response.statusCode == 200) {
      var json = response.body;
      return Food.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to Save Food.');
    }
  }
}
