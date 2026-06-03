import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class MealService {

  static const String apiKey = "f72ef8e3c04f43ec89b588af0e8f6bd4";

  Future<List<Recipe>> getRecipes() async {

    final response = await http.get(
      Uri.parse(
        "https://api.spoonacular.com/recipes/random?number=20&apiKey=$apiKey",
      ),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      List recipes = data["recipes"];

      return recipes
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
    }

    throw Exception("Tarifler alınamadı");
  }

  Future<Map<String, dynamic>> getRecipeDetail(
    int recipeId,
  ) async {

    final response = await http.get(
      Uri.parse(
        "https://api.spoonacular.com/recipes/$recipeId/information?includeNutrition=true&apiKey=$apiKey",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    

    throw Exception("Tarif detayı alınamadı");
  }
  Future<List<Recipe>> searchRecipes(String query) async {
  final encodedQuery = Uri.encodeComponent(query);

  final response = await http.get(
    Uri.parse(
      "https://api.spoonacular.com/recipes/complexSearch?query=$encodedQuery&number=20&apiKey=$apiKey",
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return (data["results"] as List)
        .map((recipe) => Recipe.fromJson(recipe))
        .toList();
  }
  throw Exception("Arama başarısız");
}
Future<List<Recipe>> searchByCategory(String category) async {
  final response = await http.get(
    Uri.parse(
      "https://api.spoonacular.com/recipes/complexSearch?type=$category&number=10&apiKey=$apiKey",
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return (data["results"] as List)
        .map((recipe) => Recipe.fromJson(recipe))
        .toList();
  }

  throw Exception("Kategori bulunamadı");
}
Future<List<dynamic>> searchByIngredients(
  List<String> ingredients,
) async {
  final ingredientString = ingredients.join(",");

  final response = await http.get(
    Uri.parse(
      "https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredientString&number=20&apiKey=$apiKey",
    ),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception("Malzemeye göre tarif bulunamadı");
}
}