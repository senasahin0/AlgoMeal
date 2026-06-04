import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../recipe/recipe_detail_screen.dart';
import '../../services/firebase_recipe_service.dart';
import '../../widgets/favorite_recipe_button.dart';

class RecipeSearchScreen extends StatefulWidget {
  final String query;
  final bool isCategory;

  const RecipeSearchScreen({
    super.key,
    required this.query,
    this.isCategory = false,
  });

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  late Future<List<Recipe>> recipesFuture;

  @override
  void initState() {
    super.initState();
    recipesFuture = FirebaseRecipeService().getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('"${widget.query}" sonuçları')),
      body: FutureBuilder<List<Recipe>>(
        future: recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Arama sırasında hata oluştu"));
          }

          final allRecipes = snapshot.data ?? [];
          final normalizedQuery = _normalize(widget.query);

          final recipes = allRecipes.where((recipe) {
            if (widget.isCategory) {
              final categoryText = _normalize(
                '${recipe.category} ${recipe.title}',
              );
              return categoryText.contains(normalizedQuery);
            }

            return _normalize(recipe.title).contains(normalizedQuery);
          }).toList();

          if (recipes.isEmpty) {
            return const Center(child: Text("Tarif bulunamadı"));
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      recipe.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.restaurant, size: 40);
                      },
                    ),
                  ),

                  title: Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: FavoriteRecipeButton(
                    recipe: recipe,
                    iconSize: 22,
                    buttonSize: 36,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }
}
