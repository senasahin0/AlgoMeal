import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/recipe.dart';

class UserProfileService {
  final CollectionReference<Map<String, dynamic>> _users = FirebaseFirestore
      .instance
      .collection('USERS');

  final CollectionReference<Map<String, dynamic>> _favorites = FirebaseFirestore
      .instance
      .collection('FAVORITES');

  Future<void> ensureUserDocument(User user, {String? name}) async {
    final ref = _users.doc(user.uid);
    final snapshot = await ref.get();
    final resolvedName = _resolveName(user, name);
    final email = user.email ?? '';

    if (snapshot.exists) {
      await ref.set({
        'uid': user.uid,
        'name': resolvedName,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await ref.set({
      'uid': user.uid,
      'name': resolvedName,
      'email': email,
      'age': 0,
      'height': 0,
      'weight': 0,
      'goal': '',
      'goalTitle': '',
      'goalDescription': '',
      'goalIcon': '',
      'dailyCalories': 2000,
      'proteinTarget': 0,
      'carbohydrateTarget': 0,
      'fatTarget': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveGoal(User user, Map<String, dynamic> goal) async {
    await _users.doc(user.uid).set({
      'goal': goal['title'] ?? '',
      'goalTitle': goal['title'] ?? '',
      'goalDescription': goal['desc'] ?? '',
      'goalIcon': '',
      'dailyCalories': goal['dailyCalories'] ?? 0,
      'proteinTarget': goal['proteinTarget'] ?? 0,
      'carbohydrateTarget': goal['carbohydrateTarget'] ?? 0,
      'fatTarget': goal['fatTarget'] ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots();
  }

  Future<void> toggleFavoriteRecipe(User user, Recipe recipe) async {
    final recipeId = recipeIdForRecipe(recipe);
    final favoriteRef = _favorites.doc(_favoriteDocumentId(user.uid, recipeId));
    final snapshot = await favoriteRef.get();

    if (snapshot.exists) {
      await favoriteRef.delete();
      return;
    }

    await favoriteRef.set(_favoriteRecipeData(user.uid, recipe, recipeId));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchFavoriteRecipe(
    String userId,
    Recipe recipe,
  ) {
    final recipeId = recipeIdForRecipe(recipe);
    return _favorites.doc(_favoriteDocumentId(userId, recipeId)).snapshots();
  }

  Stream<List<Map<String, dynamic>>> watchFavoriteRecipes(String userId) {
    return _favorites.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final favorites = snapshot.docs.map((doc) {
        final data = doc.data();
        return {...data, 'favoriteDocumentId': doc.id};
      }).toList();

      favorites.sort((first, second) {
        return _favoriteTime(second).compareTo(_favoriteTime(first));
      });

      return favorites;
    });
  }

  Recipe favoriteRecipeToRecipe(Map<String, dynamic> favorite) {
    return Recipe(
      id: _intValue(favorite['id']),
      recipeId: favorite['recipeId']?.toString() ?? '',
      title: favorite['title']?.toString() ?? '',
      image: favorite['imageUrl']?.toString() ?? '',
      readyInMinutes: _intValue(favorite['readyInMinutes']),
      servings: _intValue(favorite['servings']),
      healthScore: _doubleValue(favorite['healthScore']),
      category: favorite['category']?.toString() ?? '',
      calories: _doubleValue(favorite['calories']),
      protein: _doubleValue(favorite['protein']),
      carbs: _doubleValue(favorite['carbs']),
      fat: _doubleValue(favorite['fat']),
      ingredients: favorite['ingredients'] is List
          ? List<dynamic>.from(favorite['ingredients'] as List)
          : [],
      steps: favorite['steps'] is List
          ? List<dynamic>.from(favorite['steps'] as List)
          : [],
    );
  }

  String recipeIdForRecipe(Recipe recipe) {
    return recipe.stableRecipeId;
  }

  String _resolveName(User user, String? name) {
    final typedName = name?.trim();
    if (typedName != null && typedName.isNotEmpty) {
      return typedName;
    }

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Kullanıcı';
  }

  Map<String, dynamic> _favoriteRecipeData(
    String userId,
    Recipe recipe,
    String recipeId,
  ) {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'id': recipe.id,
      'title': recipe.title,
      'imageUrl': recipe.image,
      'readyInMinutes': recipe.readyInMinutes,
      'servings': recipe.servings,
      'healthScore': recipe.healthScore,
      'category': recipe.category,
      'calories': recipe.calories,
      'protein': recipe.protein,
      'carbs': recipe.carbs,
      'fat': recipe.fat,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String _favoriteDocumentId(String userId, String recipeId) {
    final safeRecipeId = recipeId
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    return '${userId}_$safeRecipeId';
  }

  int _favoriteTime(Map<String, dynamic> favorite) {
    final value = favorite['createdAt'];
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }

    if (value is String) {
      return DateTime.tryParse(value)?.millisecondsSinceEpoch ?? 0;
    }

    return 0;
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}
