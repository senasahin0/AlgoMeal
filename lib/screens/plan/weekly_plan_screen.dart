import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/recipe.dart';
import '../../services/firebase_recipe_service.dart';
import '../../services/user_profile_service.dart';
import '../../services/weekly_plan_service.dart';
import '../../widgets/favorite_recipe_button.dart';
import '../../widgets/nutrition_summary_card.dart';
import '../recipe/recipe_detail_screen.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  static const List<String> days = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];
  static const List<_MealSlot> mealSlots = [
    _MealSlot('breakfast', 'Kahvaltı', [
      'kahvalti',
      'breakfast',
      'yulaf',
      'omlet',
      'yumurta',
    ]),
    _MealSlot('lunch', 'Öğle Yemeği', [
      'ogle',
      'lunch',
      'salata',
      'tavuk',
      'ana',
      'makarna',
      'sebze',
    ]),
    _MealSlot('dinner', 'Akşam Yemeği', [
      'aksam',
      'dinner',
      'corba',
      'mercimek',
      'sebze',
      'ana',
      'balik',
    ]),
  ];

  final FirebaseRecipeService _recipeService = FirebaseRecipeService();
  final UserProfileService _profileService = UserProfileService();
  final WeeklyPlanService _weeklyPlanService = WeeklyPlanService();

  final Map<int, List<Map<String, String>>> _guestDayPlans = {};

  late Future<List<Recipe>> _recipesFuture;
  int selectedDayIndex = 0;
  bool isSavingPlan = false;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _recipeService.getRecipes();

    final todayIndex = DateTime.now().weekday - 1;
    selectedDayIndex = todayIndex >= 0 && todayIndex < days.length
        ? todayIndex
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(title: const Text('Planım'), centerTitle: false),
      body: user == null
          ? _buildPlanContent(profileData: null, planData: null)
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _profileService.watchUserProfile(user.uid),
              builder: (context, profileSnapshot) {
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _weeklyPlanService.watchWeeklyPlan(user.uid),
                  builder: (context, planSnapshot) {
                    return _buildPlanContent(
                      profileData: profileSnapshot.data?.data(),
                      planData: planSnapshot.data?.data(),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildPlanContent({
    required Map<String, dynamic>? profileData,
    required Map<String, dynamic>? planData,
  }) {
    final goalTitle = _goalTitle(profileData);
    final effectiveGoal = goalTitle.isEmpty ? 'Sağlıklı Beslenmek' : goalTitle;
    final targets = NutritionTargets.fromProfile(profileData);

    return FutureBuilder<List<Recipe>>(
      future: _recipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Tarifler yüklenemedi'));
        }

        final recipes = snapshot.data ?? [];
        final entries = _entriesForDay(
          recipes: recipes,
          goalTitle: effectiveGoal,
          planData: planData,
        );
        final summary = NutritionSummary.fromRecipes(
          entries.map((entry) => entry.recipe),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Haftalık Planım',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildGoalSummary(goalTitle, targets, summary),
              const SizedBox(height: 16),
              _buildDaySelector(),
              const SizedBox(height: 22),
              _buildMealsHeader(recipes, entries, effectiveGoal),
              const SizedBox(height: 10),
              if (entries.isEmpty)
                _buildEmptyDayCard(recipes, entries, effectiveGoal)
              else
                for (var i = 0; i < entries.length; i++) ...[
                  _buildMealSection(
                    entry: entries[i],
                    entryIndex: i,
                    allEntries: entries,
                  ),
                  const SizedBox(height: 14),
                ],
              const SizedBox(height: 8),
              NutritionSummaryCard(summary: summary, targets: targets),
              const SizedBox(height: 16),
              _buildFeedbackSection(summary, targets),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalSummary(
    String goalTitle,
    NutritionTargets targets,
    NutritionSummary summary,
  ) {
    final hasGoal = goalTitle.isNotEmpty;
    final calorieText = summary.calories > 0
        ? 'Plan: ${summary.calories.toStringAsFixed(0)} kcal'
        : 'Plan hazır';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.track_changes_outlined, color: Color(0xFF4CAF50)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasGoal
                      ? '$goalTitle hedefi • ${targets.calories} kcal'
                      : 'Hedef seçilmedi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  hasGoal
                      ? calorieText
                      : 'Sağlıklı beslenmeye göre öneriler gösteriliyor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final isSelected = selectedDayIndex == index;

        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            setState(() {
              selectedDayIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : Colors.grey.shade300,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Text(
              days[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMealsHeader(
    List<Recipe> recipes,
    List<_PlanEntry> entries,
    String goalTitle,
  ) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Öğünler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton.icon(
          onPressed: isSavingPlan
              ? null
              : () => _showAddMealSheet(recipes, entries, goalTitle),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Öğün Ekle'),
        ),
      ],
    );
  }

  Widget _buildMealSection({
    required _PlanEntry entry,
    required int entryIndex,
    required List<_PlanEntry> allEntries,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _slotTitle(entry.slotId, entryIndex),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildRecipeCard(entry, entryIndex, allEntries),
      ],
    );
  }

  Widget _buildRecipeCard(
    _PlanEntry entry,
    int entryIndex,
    List<_PlanEntry> allEntries,
  ) {
    final recipe = entry.recipe;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                recipe.image,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 58,
                    height: 58,
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(
                      Icons.restaurant,
                      color: Color(0xFF4CAF50),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _recipeSubtitle(recipe),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            FavoriteRecipeButton(recipe: recipe, iconSize: 22, buttonSize: 34),
            IconButton(
              tooltip: 'Öğünü çıkar',
              onPressed: isSavingPlan
                  ? null
                  : () => _removeEntry(allEntries, entryIndex),
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDayCard(
    List<Recipe> recipes,
    List<_PlanEntry> entries,
    String goalTitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu, color: Color(0xFF4CAF50), size: 34),
          const SizedBox(height: 8),
          Text(
            'Bu gün için öğün kalmadı.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _showAddMealSheet(recipes, entries, goalTitle),
            icon: const Icon(Icons.add),
            label: const Text('Öğün Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(
    NutritionSummary summary,
    NutritionTargets targets,
  ) {
    final items = _feedbackItems(summary, targets);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Geri Bildirim',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.85,
          ),
          itemBuilder: (context, index) {
            return _buildFeedbackCard(items[index]);
          },
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bugün',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _planInsight(summary, targets),
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(_FeedbackItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 22),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            item.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMealSheet(
    List<Recipe> recipes,
    List<_PlanEntry> entries,
    String goalTitle,
  ) async {
    final usedIds = entries.map((entry) => entry.recipe.stableRecipeId).toSet();
    final sortedRecipes = [...recipes]
      ..sort((first, second) {
        return _goalScore(
          second,
          goalTitle,
        ).compareTo(_goalScore(first, goalTitle));
      });

    final searchController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        String query = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredRecipes = sortedRecipes
                .where((recipe) {
                  if (usedIds.contains(recipe.stableRecipeId)) {
                    return false;
                  }

                  if (query.trim().isEmpty) {
                    return true;
                  }

                  return _normalize(recipe.title).contains(_normalize(query));
                })
                .take(30)
                .toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Öğün Ekle',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Tarif ara...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setSheetState(() {
                            query = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredRecipes.isEmpty
                            ? Center(
                                child: Text(
                                  'Eklenebilecek tarif bulunamadı',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredRecipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = filteredRecipes[index];

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        recipe.image,
                                        width: 54,
                                        height: 54,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 54,
                                                height: 54,
                                                color: const Color(0xFFE8F5E9),
                                                child: const Icon(
                                                  Icons.restaurant,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    title: Text(
                                      recipe.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(_recipeSubtitle(recipe)),
                                    trailing: const Icon(
                                      Icons.add_circle_outline,
                                    ),
                                    onTap: () async {
                                      final updatedEntries = [
                                        ...entries,
                                        _PlanEntry(
                                          slotId: 'extra',
                                          recipe: recipe,
                                        ),
                                      ];

                                      Navigator.pop(sheetContext);
                                      await _saveEntries(updatedEntries);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    searchController.dispose();
  }

  Future<void> _removeEntry(List<_PlanEntry> entries, int entryIndex) async {
    final updatedEntries = [...entries]..removeAt(entryIndex);
    await _saveEntries(updatedEntries);
  }

  Future<void> _saveEntries(List<_PlanEntry> entries) async {
    final user = FirebaseAuth.instance.currentUser;
    final entryData = entries.map(_entryToData).toList();

    if (user == null) {
      setState(() {
        _guestDayPlans[selectedDayIndex] = entryData;
      });
      return;
    }

    setState(() {
      isSavingPlan = true;
    });

    try {
      await _weeklyPlanService.saveDayEntries(
        userId: user.uid,
        dayIndex: selectedDayIndex,
        entries: entryData,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan güncellenirken hata oluştu')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingPlan = false;
        });
      }
    }
  }

  List<_PlanEntry> _entriesForDay({
    required List<Recipe> recipes,
    required String goalTitle,
    required Map<String, dynamic>? planData,
  }) {
    final recipeById = {
      for (final recipe in recipes) recipe.stableRecipeId: recipe,
    };

    final storedEntries =
        _guestDayPlans[selectedDayIndex] ??
        _storedEntriesForDay(planData, selectedDayIndex);

    if (storedEntries != null) {
      return storedEntries
          .map((entry) {
            final recipe = recipeById[entry['recipeId']];
            if (recipe == null) {
              return null;
            }

            return _PlanEntry(
              slotId: entry['slotId'] ?? 'extra',
              recipe: recipe,
            );
          })
          .whereType<_PlanEntry>()
          .toList();
    }

    return _suggestedEntriesForDay(recipes, goalTitle);
  }

  List<_PlanEntry> _suggestedEntriesForDay(
    List<Recipe> recipes,
    String goalTitle,
  ) {
    if (recipes.isEmpty) {
      return [];
    }

    final rankedRecipes = [...recipes]
      ..sort((first, second) {
        return _goalScore(
          second,
          goalTitle,
        ).compareTo(_goalScore(first, goalTitle));
      });

    final usedRecipeKeys = <String>{};
    final entries = <_PlanEntry>[];

    for (var slotIndex = 0; slotIndex < mealSlots.length; slotIndex++) {
      final slot = mealSlots[slotIndex];
      final recipe = _pickRecipeForSlot(
        rankedRecipes,
        slot,
        slotIndex,
        usedRecipeKeys,
      );

      if (recipe != null) {
        usedRecipeKeys.add(recipe.stableRecipeId);
        entries.add(_PlanEntry(slotId: slot.id, recipe: recipe));
      }
    }

    return entries;
  }

  Recipe? _pickRecipeForSlot(
    List<Recipe> rankedRecipes,
    _MealSlot slot,
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
        (selectedDayIndex * mealSlots.length + slotIndex) % pool.length;
    return pool[recipeIndex];
  }

  bool _matchesSlot(Recipe recipe, _MealSlot slot) {
    final searchableText = _normalize('${recipe.category} ${recipe.title}');

    return slot.keywords.any(searchableText.contains);
  }

  List<Map<String, String>>? _storedEntriesForDay(
    Map<String, dynamic>? planData,
    int dayIndex,
  ) {
    final daysMap = planData?['days'];
    if (daysMap is! Map) {
      return null;
    }

    final dayKey = dayIndex.toString();
    if (!daysMap.containsKey(dayKey)) {
      return null;
    }

    final rawEntries = daysMap[dayKey];
    if (rawEntries is! List) {
      return [];
    }

    return rawEntries
        .map<Map<String, String>>((entry) {
          if (entry is String) {
            return {'slotId': 'extra', 'recipeId': entry};
          }

          if (entry is Map) {
            return {
              'slotId':
                  entry['slotId']?.toString() ??
                  entry['slot']?.toString() ??
                  'extra',
              'recipeId': entry['recipeId']?.toString() ?? '',
            };
          }

          return {'slotId': 'extra', 'recipeId': ''};
        })
        .where((entry) {
          return entry['recipeId']!.isNotEmpty;
        })
        .toList();
  }

  Map<String, String> _entryToData(_PlanEntry entry) {
    return {'slotId': entry.slotId, 'recipeId': entry.recipe.stableRecipeId};
  }

  List<_FeedbackItem> _feedbackItems(
    NutritionSummary summary,
    NutritionTargets targets,
  ) {
    return [
      _macroFeedback(
        label: 'Karbonhidrat',
        value: summary.carbs,
        target: targets.carbs,
        icon: Icons.warning_amber_rounded,
        balancedIcon: Icons.check,
        color: Colors.orange,
      ),
      _macroFeedback(
        label: 'Protein',
        value: summary.protein,
        target: targets.protein,
        icon: Icons.fitness_center_outlined,
        balancedIcon: Icons.check,
        color: const Color(0xFF4CAF50),
      ),
      _calorieFeedback(summary, targets),
      _macroFeedback(
        label: 'Yağ',
        value: summary.fat,
        target: targets.fat,
        icon: Icons.water_drop_outlined,
        balancedIcon: Icons.check,
        color: Colors.blue,
      ),
    ];
  }

  _FeedbackItem _macroFeedback({
    required String label,
    required double value,
    required double target,
    required IconData icon,
    required IconData balancedIcon,
    required Color color,
  }) {
    final ratio = target > 0 ? value / target : 0.0;

    if (ratio > 1.1) {
      return _FeedbackItem(
        icon: icon,
        title: '$label fazla',
        message: '%${((ratio - 1) * 100).round()} hedef üstü',
        color: color,
      );
    }

    if (ratio < 0.7) {
      return _FeedbackItem(
        icon: icon,
        title: '$label düşük',
        message: '%${((1 - ratio) * 100).round()} hedef altı',
        color: color,
      );
    }

    return _FeedbackItem(
      icon: balancedIcon,
      title: '$label dengeli',
      message: 'Hedef aralığında',
      color: color,
    );
  }

  _FeedbackItem _calorieFeedback(
    NutritionSummary summary,
    NutritionTargets targets,
  ) {
    final difference = summary.calories - targets.calories;
    final ratio = targets.calories > 0
        ? summary.calories / targets.calories
        : 0;

    if (ratio > 1.05) {
      return _FeedbackItem(
        icon: Icons.local_fire_department_outlined,
        title: 'Kalori yüksek',
        message: '+${difference.toStringAsFixed(0)} kcal',
        color: Colors.orange,
      );
    }

    if (ratio < 0.75) {
      return _FeedbackItem(
        icon: Icons.local_fire_department_outlined,
        title: 'Kalori düşük',
        message: '${difference.toStringAsFixed(0)} kcal',
        color: Colors.blue,
      );
    }

    return const _FeedbackItem(
      icon: Icons.check,
      title: 'Kalori dengeli',
      message: 'Hedef aralığında',
      color: Color(0xFF4CAF50),
    );
  }

  String _planInsight(NutritionSummary summary, NutritionTargets targets) {
    final carbRatio = targets.carbs > 0 ? summary.carbs / targets.carbs : 0.0;
    final proteinRatio = targets.protein > 0
        ? summary.protein / targets.protein
        : 0.0;
    final calorieRatio = targets.calories > 0
        ? summary.calories / targets.calories
        : 0.0;
    final fatRatio = targets.fat > 0 ? summary.fat / targets.fat : 0.0;

    final messages = <String>[];

    if (carbRatio > 1.1) {
      messages.add(
        'Karbonhidrat hedefinin %${((carbRatio - 1) * 100).round()} üzerindesin; pilav, makarna veya tahıl ağırlıklı öğünlerden birini sebze/protein ağırlıklı tarifle değiştirebilirsin.',
      );
    } else if (carbRatio < 0.7) {
      messages.add(
        'Karbonhidrat düşük kalmış; enerji için bir öğüne tam tahıl, baklagil veya meyve ekleyebilirsin.',
      );
    }

    if (proteinRatio < 0.7) {
      messages.add(
        'Protein hedefe yaklaşmadı; tavuk, yumurta, yoğurt veya baklagil içeren bir ek öğün iyi olur.',
      );
    } else {
      messages.add(
        'Protein tarafı iyi görünüyor; kas ve tokluk hedefini destekliyor.',
      );
    }

    if (calorieRatio > 1.05) {
      messages.add(
        'Kalori hedefini biraz aştın; akşam öğününü daha hafif seçebilirsin.',
      );
    } else if (calorieRatio < 0.75) {
      messages.add(
        'Kalori açığın yüksek; sürdürülebilirlik için küçük bir ara öğün ekleyebilirsin.',
      );
    }

    if (fatRatio > 1.1) {
      messages.add(
        'Yağ tüketimi yüksek; yağlı sos ve kızartma yerine haşlama veya fırın tarifleri seç.',
      );
    }

    if (messages.isEmpty) {
      return 'Planın hedeflerine oldukça dengeli yaklaşıyor. Bugünü bu plana yakın sürdürürsen makro dağılımın iyi kalır.';
    }

    return messages.join(' ');
  }

  String _slotTitle(String slotId, int entryIndex) {
    final slot = mealSlots.where((slot) => slot.id == slotId).firstOrNull;
    if (slot != null) {
      return slot.title;
    }

    return 'Ek Öğün ${entryIndex + 1}';
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

  String _recipeSubtitle(Recipe recipe) {
    if (recipe.calories > 0) {
      return '${recipe.calories.toStringAsFixed(0)} kcal';
    }

    if (recipe.readyInMinutes > 0) {
      return '${recipe.readyInMinutes} dk';
    }

    return 'Tarif detayı';
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

class _MealSlot {
  final String id;
  final String title;
  final List<String> keywords;

  const _MealSlot(this.id, this.title, this.keywords);
}

class _PlanEntry {
  final String slotId;
  final Recipe recipe;

  const _PlanEntry({required this.slotId, required this.recipe});
}

class _FeedbackItem {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _FeedbackItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });
}
