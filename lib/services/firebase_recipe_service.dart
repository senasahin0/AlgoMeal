import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class FirebaseRecipeService {
  Future<List<Recipe>> getRecipes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('RECIPES')
        .get();

    print("Bulunan tarif sayısı: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Recipe(
         id: 0,
  title: data['title'] ?? '',
  image: data['imageUrl'] ?? '',
  readyInMinutes: data['readyInMinutes'] ?? 0,
  servings: data['servings'] ?? 0,
  healthScore: (data['healthScore'] ?? 0).toDouble(),

  category: data['category'] ?? '',

  calories: (data['calories'] ?? 0).toDouble(),
  protein: (data['protein'] ?? 0).toDouble(),
  carbs: (data['carbs'] ?? 0).toDouble(),
  fat: (data['fat'] ?? 0).toDouble(),

  ingredients: data['ingredients'] ?? [],
  steps: data['steps'] ?? [],
      );
    }).toList();
  }
}