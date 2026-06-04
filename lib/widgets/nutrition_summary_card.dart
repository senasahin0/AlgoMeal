import 'package:flutter/material.dart';

import '../models/recipe.dart';

class NutritionSummary {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionSummary.fromRecipes(Iterable<Recipe> recipes) {
    return NutritionSummary(
      calories: recipes.fold(0, (total, recipe) => total + recipe.calories),
      protein: recipes.fold(0, (total, recipe) => total + recipe.protein),
      carbs: recipes.fold(0, (total, recipe) => total + recipe.carbs),
      fat: recipes.fold(0, (total, recipe) => total + recipe.fat),
    );
  }
}

class NutritionTargets {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionTargets.fromProfile(Map<String, dynamic>? data) {
    final calories = _intValue(data?['dailyCalories']);
    final protein = _doubleValue(data?['proteinTarget']);
    final carbs = _doubleValue(data?['carbohydrateTarget']);
    final fat = _doubleValue(data?['fatTarget']);

    return NutritionTargets(
      calories: calories > 0 ? calories : 2000,
      protein: protein > 0 ? protein : 90,
      carbs: carbs > 0 ? carbs : 240,
      fat: fat > 0 ? fat : 70,
    );
  }

  static int _intValue(dynamic value) {
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

  static double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}

class NutritionSummaryCard extends StatelessWidget {
  final NutritionSummary summary;
  final NutritionTargets targets;

  const NutritionSummaryCard({
    super.key,
    required this.summary,
    required this.targets,
  });

  @override
  Widget build(BuildContext context) {
    final remainingCalories = targets.calories - summary.calories;
    final remainingLabel = remainingCalories >= 0 ? 'Kalan kcal' : 'Aşım kcal';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Günün Özeti',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryNumber(
                  value: summary.calories.toStringAsFixed(0),
                  label: 'Toplam kcal',
                  valueColor: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryNumber(
                  value: remainingCalories.abs().toStringAsFixed(0),
                  label: remainingLabel,
                  valueColor: remainingCalories >= 0
                      ? const Color(0xFF4CAF50)
                      : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MacroProgress(
            label: 'Protein',
            value: summary.protein,
            target: targets.protein,
            color: const Color(0xFF4CAF50),
          ),
          _MacroProgress(
            label: 'Karbonhidrat',
            value: summary.carbs,
            target: targets.carbs,
            color: Colors.orange,
          ),
          _MacroProgress(
            label: 'Yağ',
            value: summary.fat,
            target: targets.fat,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _SummaryNumber extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _SummaryNumber({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroProgress extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final Color color;

  const _MacroProgress({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.25) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 98,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                color: color,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            child: Text(
              '${value.toStringAsFixed(0)}g',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
