import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../recipe/recipe_detail_screen.dart';
import '../../services/firebase_recipe_service.dart';
import '../../widgets/favorite_recipe_button.dart';

class IngredientSearchScreen extends StatefulWidget {
  final List<String> ingredients;

  const IngredientSearchScreen({super.key, required this.ingredients});

  @override
  State<IngredientSearchScreen> createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  late Future<List<Recipe>> recipesFuture;

  @override
  void initState() {
    super.initState();
    recipesFuture = FirebaseRecipeService().getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Malzemeye Göre Tarifler")),
      body: FutureBuilder<List<Recipe>>(
        future: recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final allRecipes = snapshot.data ?? [];

          final recipes = allRecipes.where((recipe) {
            final recipeIngredients = recipe.ingredients
                .map((e) => e.toString().toLowerCase())
                .toList();

            return widget.ingredients.any(
              (ingredient) => recipeIngredients.any(
                (item) => item.contains(ingredient.toLowerCase()),
              ),
            );
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
                        return const Icon(Icons.restaurant);
                      },
                    ),
                  ),
                  title: Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text("${recipe.ingredients.length} malzeme"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FavoriteRecipeButton(
                        recipe: recipe,
                        iconSize: 22,
                        buttonSize: 36,
                      ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
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
}
