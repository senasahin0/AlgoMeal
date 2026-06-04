import 'package:flutter/material.dart';
import 'recipe_search_screen.dart';
import 'ingredient_search_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController ingredientController = TextEditingController();

  final List<String> ingredients = [];

  final List<Map<String, dynamic>> categories = [
    {
      "name": "Kahvaltı",
      "apiType": "Kahvaltı",
      "imageUrl":
          "https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=500&q=80",
    },
    {
      "name": "Ana Yemek",
      "apiType": "Ana Yemek",
      "imageUrl":
          "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=500&q=80",
    },
    {
      "name": "Çorba",
      "apiType": "Çorba",
      "imageUrl":
          "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=500&q=80",
    },
    {
      "name": "Salata",
      "apiType": "Salata",
      "imageUrl":
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=500&q=80",
    },
    {
      "name": "Tatlı",
      "apiType": "Tatlı",
      "imageUrl":
          "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=500&q=80",
    },
    {
      "name": "Atıştırmalık",
      "apiType": "Atıştırmalık",
      "imageUrl":
          "https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=500&q=80",
    },
  ];

  void addIngredient() {
    if (ingredientController.text.trim().isEmpty) return;

    setState(() {
      ingredients.add(ingredientController.text.trim());
    });

    ingredientController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(title: const Text("Tarif Ara"), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH BAR
            TextField(
              controller: searchController,

              onSubmitted: (value) {
                if (value.trim().isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeSearchScreen(query: value),
                  ),
                );
              },

              decoration: InputDecoration(
                hintText: "Yemek adı, malzeme veya kategori ara...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Kategoriler",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeSearchScreen(
                          query: categories[index]["apiType"],
                          isCategory: true,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            categories[index]["imageUrl"],
                            width: double.infinity,
                            height: 86,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 86,
                                color: const Color(0xFFE8F5E9),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF4CAF50),
                                  size: 34,
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    categories[index]["name"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF4CAF50),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "Malzemeye Göre Ara",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ingredientController,
                    decoration: InputDecoration(
                      hintText: "Malzeme ekle...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: addIngredient,
                  child: const Text("Ekle"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ingredients.map((ingredient) {
                return Chip(
                  backgroundColor: const Color(0xFFE8F5E9),
                  label: Text(
                    ingredient,
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      ingredients.remove(ingredient);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (ingredients.isEmpty) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          IngredientSearchScreen(ingredients: ingredients),
                    ),
                  );
                },
                child: const Text("Tarifleri Göster"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
