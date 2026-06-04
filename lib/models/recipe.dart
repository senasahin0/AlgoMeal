class Recipe {
  final int id;
  final String recipeId;
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final double healthScore;

  final String category;

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  final List<dynamic> ingredients;
  final List<dynamic> steps;

  Recipe({
    required this.id,
    this.recipeId = '',
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.healthScore,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? 0,
      recipeId: json['recipeId']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      image: json['imageUrl'] ?? '',
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      healthScore: (json['healthScore'] ?? 0).toDouble(),

      category: json['category'] ?? '',

      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),

      ingredients: json['ingredients'] ?? [],
      steps: json['steps'] ?? [],
    );
  }

  String get stableRecipeId {
    if (recipeId.trim().isNotEmpty) {
      return recipeId.trim();
    }

    if (id > 0) {
      return id.toString();
    }

    final titleKey = title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9ğüşıöç]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    return titleKey.isNotEmpty ? titleKey : 'unknown_recipe';
  }
}
