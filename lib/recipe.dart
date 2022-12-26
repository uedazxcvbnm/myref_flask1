// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

List<Recipe> recipeFromJson(String str) =>
    List<Recipe>.from(json.decode(str).map((x) => Recipe.fromJson(x)));

List<Food> turnOnFromJson(String str) =>
    List<Food>.from(json.decode(str).map((x) => Food.fromJson(x)));

String recipeToJson(List<Recipe> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Recipe {
  Recipe({
    required this.id,
    required this.image,
    required this.url,
  });

  int id;
  String image;
  String url;

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json["id"],
        image: json["image"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "url": url,
      };
  /*@override
  String toString() {
    String result = url;
    return result;
  }*/
}

class Food {
  Food({required this.id, required this.name});
  int id;
  String name;
  factory Food.fromJson(Map<String, dynamic> json) =>
      Food(id: json["id"], name: json["name"]);
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
  @override
  String toString() {
    String result = name;
    return result;
  }
}
