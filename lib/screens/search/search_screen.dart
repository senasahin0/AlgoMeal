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
  {"emoji": "🍳", "name": "Kahvaltı","apiType":"Kahvaltı"},
  {"emoji": "🍗", "name": "Ana Yemek","apiType":"Ana Yemek"},
  {"emoji": "🍲", "name": "Çorba","apiType":"Çorba"},
  {"emoji": "🥗", "name": "Salata","apiType":"Salata"},
  {"emoji": "🍰", "name": "Tatlı","apiType":"Tatlı"},
  {"emoji": "🥨", "name": "Atıştırmalık","apiType":"Atıştırmalık"},
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
      appBar: AppBar(
        title: const Text("Tarif Ara"),
        centerTitle: false,
      ),
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
        builder: (_) => RecipeSearchScreen(
          query: value,
        ),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
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
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ],
),
      child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categories[index]["emoji"],
        style: const TextStyle(fontSize: 28),
      ),
    ),
    const SizedBox(height: 10),
    Text(
      categories[index]["name"],
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                  label: Text(ingredient,style:const TextStyle(
                    color: Color(0xFF2E7D32),
      fontWeight: FontWeight.w500,
                  )),
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
          IngredientSearchScreen(
        ingredients: ingredients,
      ),
    ),
  );
                },
                child: const Text("Tarifleri Göster"),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "En Çok Aratılan Tarifler",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: const Color(0xFFE8F5E9),
                      child: Icon(Icons.restaurant,color:Color(0xFF4CAF50)),
                    ),
                    title: Text("Tarif ${index + 1}"),
                    subtitle: const Text("350 kcal"),
                    trailing: const Icon(Icons.favorite_border,
                     color: Color(0xFF4CAF50),),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}