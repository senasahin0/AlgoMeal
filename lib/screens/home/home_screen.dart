import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../../services/firebase_recipe_service.dart';
import '../recipe/recipe_detail_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = [
    const HomePageContent(),
    const Center(child: Text("Hedefler")),
    const SearchScreen(),
    const Center(child: Text("Planım")),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Hedefler"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Ara"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Planım"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
final FirebaseRecipeService mealService =
    FirebaseRecipeService();
  late Future<List<Recipe>> recipes;

  @override
  void initState() {
    super.initState();
    recipes = mealService.getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Recipe>>(
        future: recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Tarifler yüklenemedi"));
          }

          final meals = snapshot.data ?? [];
          final gununTarifi = meals.isNotEmpty ? meals.first : null;

          // Maksimum 10 eleman listelemek için veriyi sınırla
          final popularMeals = meals.length > 10 ? meals.sublist(0, 10) : meals;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Merhaba Büşra 👋
                const Text(
                  "Merhaba Büşra 👋",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 2. 🍽️ Günün Tarifi
                if (gununTarifi != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🍽️ Günün Tarifi",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gununTarifi.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("${gununTarifi.readyInMinutes} dk • ${gununTarifi.servings} porsiyon"),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(recipe: gununTarifi),
                              ),
                            );
                          },
                          child: const Text("Tarife Git"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 3. 🔥 Günlük Kalori
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🔥 Günlük Kalori",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "1240 / 2000 kcal",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(value: 0.62, minHeight: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. 🍳 Kategoriler
                const Text(
                  "🍳 Kategoriler",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _categoryChip("🍳 Kahvaltı"),
                      _categoryChip("🥗 Salata"),
                      _categoryChip("🍝 Ana Yemek"),
                      _categoryChip("🍲 Çorba"),
                      _categoryChip("🥨 Atıştırmalık"),
                      _categoryChip("🍰 Tatlı"),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 5. ⭐ Popüler Tarifler
                const Text(
                  "⭐ Popüler Tarifler",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                
                // ASLA HATA VERMEYEN YATAY KAYDIRMA YAPISI
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: popularMeals.map((meal) {
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 15, bottom: 5),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(recipe: meal),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    meal.image,
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 100,
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(Icons.restaurant, size: 40),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${meal.readyInMinutes} dk",
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.people, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${meal.servings} por.",
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Sağlık: ${meal.healthScore.toInt()}",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

Widget _categoryChip(String title) {
  return Container(
    width: 120,
    margin: const EdgeInsets.only(right: 10),

    child: Chip(
      label: Center(
        child: Text(
          title,
          overflow: TextOverflow.visible,
        ),
      ),

      backgroundColor: Colors.green.shade50,
      side: BorderSide.none,
    ),
  );
} 
}