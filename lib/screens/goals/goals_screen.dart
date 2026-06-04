import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/user_profile_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final UserProfileService _profileService = UserProfileService();

  int selectedIndex = 0;
  bool isSaving = false;

  final List<Map<String, dynamic>> goals = [
    {
      'icon': Icons.monitor_weight_outlined,
      'title': 'Kilo Vermek',
      'desc': 'Düşük kalorili ve yüksek proteinli plan',
      'dailyCalories': 1600,
      'proteinTarget': 110,
      'carbohydrateTarget': 150,
      'fatTarget': 50,
    },
    {
      'icon': Icons.eco_outlined,
      'title': 'Sağlıklı Beslenmek',
      'desc': 'Dengeli ve sürdürülebilir beslenme',
      'dailyCalories': 2000,
      'proteinTarget': 90,
      'carbohydrateTarget': 240,
      'fatTarget': 70,
    },
    {
      'icon': Icons.trending_up,
      'title': 'Kilo Almak',
      'desc': 'Kalori fazlası ve enerji odaklı plan',
      'dailyCalories': 2600,
      'proteinTarget': 115,
      'carbohydrateTarget': 330,
      'fatTarget': 85,
    },
    {
      'icon': Icons.fitness_center,
      'title': 'Kas Yapmak',
      'desc': 'Yüksek protein ve kas yapıcı besinler içeren plan',
      'dailyCalories': 2400,
      'proteinTarget': 145,
      'carbohydrateTarget': 260,
      'fatTarget': 75,
    },
  ];

  Map<String, dynamic> get selectedGoal => goals[selectedIndex];

  Future<void> _saveSelectedGoal() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hedef kaydetmek için giriş yapmalısın')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _profileService.saveGoal(user, selectedGoal);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedGoal['title']} hedefi kaydedildi')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hedef kaydedilirken bir hata oluştu')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FA),
      appBar: AppBar(title: const Text('Hedefler'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              ' Hedefini Seç',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hedefini seç ve sana uygun tarifleri görelim.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  return _buildGoalCard(goals[index], index);
                },
              ),
            ),
            _buildSelectedGoalCard(selectedGoal),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: isSaving ? null : _saveSelectedGoal,
                child: Text(
                  isSaving ? 'Kaydediliyor...' : 'Hedefi Kaydet',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            _buildGoalIcon(goal['icon'] as IconData, isSelected),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal['desc'] as String,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalIcon(IconData icon, bool isSelected) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFDDF3E1) : const Color(0xFFF1F5F1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade700,
        size: 25,
      ),
    );
  }

  Widget _buildSelectedGoalCard(Map<String, dynamic> goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seçilen Hedef',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            goal['title'] as String,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(goal['desc'] as String),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTargetTile(
                  Icons.local_fire_department_outlined,
                  'Günlük Kalori',
                  '${goal['dailyCalories']} kcal',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTargetTile(
                  Icons.fitness_center_outlined,
                  'Protein',
                  '${goal['proteinTarget']} g',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTargetTile(
                  Icons.grain_outlined,
                  'Karbonhidrat',
                  '${goal['carbohydrateTarget']} g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTargetTile(
                  Icons.water_drop_outlined,
                  'Yağ',
                  '${goal['fatTarget']} g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetTile(IconData icon, String label, String value) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
