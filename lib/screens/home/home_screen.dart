import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/recipe.dart';
import '../../services/firebase_recipe_service.dart';
import '../../services/user_profile_service.dart';
import '../../services/weekly_plan_service.dart';
import '../../widgets/favorite_recipe_button.dart';
import '../../widgets/nutrition_summary_card.dart';
import '../goals/goals_screen.dart';
import '../plan/weekly_plan_screen.dart';
import '../profile/profile_screen.dart';
import '../recipe/recipe_detail_screen.dart';
import '../search/recipe_search_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeMealSlot {
  final List<String> keywords;

  const _HomeMealSlot(this.keywords);
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [
    HomePageContent(),
    GoalsScreen(),
    SearchScreen(),
    WeeklyPlanScreen(),
    ProfileScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Hedefler'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Ara'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Planım',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
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
  static const List<_HomeMealSlot> _mealSlots = [
    _HomeMealSlot(['kahvalti', 'breakfast', 'yulaf', 'omlet']),
    _HomeMealSlot(['ogle', 'lunch', 'salata', 'tavuk', 'ana']),
    _HomeMealSlot(['aksam', 'dinner', 'corba', 'sebze', 'ana']),
  ];

  final FirebaseRecipeService _recipeService = FirebaseRecipeService();
  final UserProfileService _profileService = UserProfileService();
  final WeeklyPlanService _weeklyPlanService = WeeklyPlanService();

  late Future<List<Recipe>> _recipesFuture;

  final List<Map<String, String>> _categories = const [
    {'emoji': '🍳', 'name': 'Kahvaltı', 'apiType': 'Kahvaltı'},
    {'emoji': '🥗', 'name': 'Salata', 'apiType': 'Salata'},
    {'emoji': '🍝', 'name': 'Ana Yemek', 'apiType': 'Ana Yemek'},
    {'emoji': '🍲', 'name': 'Çorba', 'apiType': 'Çorba'},
    {'emoji': '🥨', 'name': 'Atıştırmalık', 'apiType': 'Atıştırmalık'},
    {'emoji': '🍰', 'name': 'Tatlı', 'apiType': 'Tatlı'},
  ];

  @override
  void initState() {
    super.initState();
    _recipesFuture = _recipeService.getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greetingName = _displayName(user);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDFCF9), Color(0xFFF7F6F3)],
        ),
      ),
      child: SafeArea(
        child: user == null
            ? _buildRecipeContent(greetingName, null, null)
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _profileService.watchUserProfile(user.uid),
                builder: (context, profileSnapshot) {
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _weeklyPlanService.watchWeeklyPlan(user.uid),
                    builder: (context, planSnapshot) {
                      return _buildRecipeContent(
                        greetingName,
                        profileSnapshot.data?.data(),
                        planSnapshot.data?.data(),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRecipeContent(
    String greetingName,
    Map<String, dynamic>? profileData,
    Map<String, dynamic>? planData,
  ) {
    return FutureBuilder<List<Recipe>>(
      future: _recipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Tarifler yüklenemedi'));
        }

        final meals = snapshot.data ?? [];
        final goalTitle = _goalTitle(profileData);
        final effectiveGoal = goalTitle.isEmpty
            ? 'Sağlıklı Beslenmek'
            : goalTitle;
        final dailyRecipe = _selectDailyRecipe(meals, effectiveGoal);
        final popularMeals = _popularRecipes(meals, effectiveGoal);
        final todayPlanRecipes = _todayPlanRecipes(
          recipes: meals,
          goalTitle: effectiveGoal,
          planData: planData,
        );
        final dailySummary = NutritionSummary.fromRecipes(todayPlanRecipes);
        final targets = NutritionTargets.fromProfile(profileData);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba $greetingName',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                goalTitle.isEmpty
                    ? 'Bugün sağlıklı bir öğünle başlayalım'
                    : '$goalTitle hedefine uygun öneriler hazır',
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (dailyRecipe != null) ...[
                _buildDailyRecipeCard(dailyRecipe),
                const SizedBox(height: 20),
              ],
              NutritionSummaryCard(summary: dailySummary, targets: targets),
              const SizedBox(height: 20),
              const Text(
                'Kategoriler',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((category) {
                    return _categoryChip(
                      emoji: category['emoji']!,
                      name: category['name']!,
                      apiType: category['apiType']!,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Popüler Tarifler',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              if (popularMeals.isEmpty)
                Text(
                  'Henüz gösterilecek tarif yok.',
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: popularMeals
                        .map(_buildPopularRecipeCard)
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyRecipeCard(Recipe recipe) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBF6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              recipe.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.green.shade100,
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Günün Seçimi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FavoriteRecipeButton(
                      recipe: recipe,
                      iconSize: 22,
                      buttonSize: 36,
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 18),
                    const SizedBox(width: 4),
                    Text('${recipe.readyInMinutes} dk'),
                    const SizedBox(width: 20),
                    const Icon(Icons.restaurant, size: 18),
                    const SizedBox(width: 4),
                    Text('${recipe.servings} porsiyon'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _openRecipe(recipe),
                    child: const Text('Tarifi İncele'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRecipeCard(Recipe meal) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 15, bottom: 5),
      child: InkWell(
        onTap: () => _openRecipe(meal),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            meal.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FavoriteRecipeButton(
                          recipe: meal,
                          iconSize: 20,
                          buttonSize: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.readyInMinutes} dk',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.servings} por.',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sağlık: ${meal.healthScore.toInt()}',
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
  }

  Widget _categoryChip({
    required String emoji,
    required String name,
    required String apiType,
  }) {
    return Container(
      width: 95,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RecipeSearchScreen(query: apiType, isCategory: true),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Recipe> _todayPlanRecipes({
    required List<Recipe> recipes,
    required String goalTitle,
    required Map<String, dynamic>? planData,
  }) {
    if (recipes.isEmpty) {
      return [];
    }

    final todayIndex = DateTime.now().weekday - 1;
    final recipeById = {
      for (final recipe in recipes) recipe.stableRecipeId: recipe,
    };
    final storedEntries = _storedEntriesForDay(planData, todayIndex);

    if (storedEntries != null) {
      return storedEntries
          .map((entry) => recipeById[entry['recipeId']])
          .whereType<Recipe>()
          .toList();
    }

    return _suggestedPlanRecipes(recipes, goalTitle, todayIndex);
  }

  List<Map<String, String>>? _storedEntriesForDay(
    Map<String, dynamic>? planData,
    int dayIndex,
  ) {
    final daysMap = planData?['days'];
    if (daysMap is! Map) {
      return null;
    }

    final rawEntries = daysMap[dayIndex.toString()];
    if (rawEntries == null) {
      return null;
    }

    if (rawEntries is! List) {
      return [];
    }

    return rawEntries
        .map<Map<String, String>>((entry) {
          if (entry is String) {
            return {'recipeId': entry};
          }

          if (entry is Map) {
            return {'recipeId': entry['recipeId']?.toString() ?? ''};
          }

          return {'recipeId': ''};
        })
        .where((entry) => entry['recipeId']!.isNotEmpty)
        .toList();
  }

  List<Recipe> _suggestedPlanRecipes(
    List<Recipe> recipes,
    String goalTitle,
    int dayIndex,
  ) {
    final rankedRecipes = [...recipes]
      ..sort((first, second) {
        return _goalScore(
          second,
          goalTitle,
        ).compareTo(_goalScore(first, goalTitle));
      });
    final usedRecipeKeys = <String>{};
    final selectedRecipes = <Recipe>[];

    for (var slotIndex = 0; slotIndex < _mealSlots.length; slotIndex++) {
      final recipe = _pickRecipeForSlot(
        rankedRecipes,
        _mealSlots[slotIndex],
        dayIndex,
        slotIndex,
        usedRecipeKeys,
      );

      if (recipe != null) {
        usedRecipeKeys.add(recipe.stableRecipeId);
        selectedRecipes.add(recipe);
      }
    }

    return selectedRecipes;
  }

  Recipe? _pickRecipeForSlot(
    List<Recipe> rankedRecipes,
    _HomeMealSlot slot,
    int dayIndex,
    int slotIndex,
    Set<String> usedRecipeKeys,
  ) {
    final preferredRecipes = rankedRecipes.where((recipe) {
      return !usedRecipeKeys.contains(recipe.stableRecipeId) &&
          _matchesSlot(recipe, slot);
    }).toList();
    final fallbackRecipes = rankedRecipes.where((recipe) {
      return !usedRecipeKeys.contains(recipe.stableRecipeId);
    }).toList();
    final pool = preferredRecipes.isNotEmpty
        ? preferredRecipes
        : fallbackRecipes;

    if (pool.isEmpty) {
      return null;
    }

    final recipeIndex =
        (dayIndex * _mealSlots.length + slotIndex) % pool.length;
    return pool[recipeIndex];
  }

  bool _matchesSlot(Recipe recipe, _HomeMealSlot slot) {
    final searchableText = _normalize('${recipe.category} ${recipe.title}');
    return slot.keywords.any(searchableText.contains);
  }

  List<Recipe> _popularRecipes(List<Recipe> meals, String goalTitle) {
    final rankedMeals = [...meals]
      ..sort((first, second) {
        return _goalScore(
          second,
          goalTitle,
        ).compareTo(_goalScore(first, goalTitle));
      });

    return rankedMeals.take(10).toList();
  }

  Recipe? _selectDailyRecipe(List<Recipe> meals, String goalTitle) {
    if (meals.isEmpty) {
      return null;
    }

    final rankedMeals = _popularRecipes(meals, goalTitle);
    final dayIndex = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    final goalOffset = goalTitle.codeUnits.fold<int>(
      0,
      (total, code) => total + code,
    );
    final selectedIndex = (dayIndex + goalOffset) % rankedMeals.length;

    return rankedMeals[selectedIndex];
  }

  double _goalScore(Recipe recipe, String goalTitle) {
    final goal = _normalize(goalTitle);
    final calories = recipe.calories > 0 ? recipe.calories : 500;
    final protein = recipe.protein;
    final carbs = recipe.carbs;
    final fat = recipe.fat;
    final health = recipe.healthScore;

    if (goal.contains('kilo vermek')) {
      return (health * 2.2) + (protein * 2.4) - (calories * 0.24) - (fat * 0.6);
    }

    if (goal.contains('kilo almak')) {
      return (calories * 0.45) +
          (protein * 1.4) +
          (carbs * 0.45) +
          health -
          (fat * 0.1);
    }

    if (goal.contains('kas yapmak')) {
      return (protein * 3.2) +
          (health * 1.4) +
          (calories * 0.08) -
          (fat * 0.25);
    }

    return (health * 3) +
        (protein * 1.1) -
        ((calories - 500).abs() * 0.08) -
        (fat * 0.2);
  }

  void _openRecipe(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
    );
  }

  String _displayName(User? user) {
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Misafir';
  }

  String _goalTitle(Map<String, dynamic>? data) {
    final title = data?['goalTitle'];
    if (title is String && title.trim().isNotEmpty) {
      return title.trim();
    }

    final legacyTitle = data?['goal'];
    if (legacyTitle is String && legacyTitle.trim().isNotEmpty) {
      return legacyTitle.trim();
    }

    return '';
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
