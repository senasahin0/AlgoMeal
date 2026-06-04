import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/recipe_comment_service.dart';
import '../../services/user_profile_service.dart';
import '../auth/login_screen.dart';
import '../recipe/recipe_detail_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final UserProfileService _profileService = UserProfileService();
  static final RecipeCommentService _commentService = RecipeCommentService();

  String _displayName(User? user) {
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Misafir Kullanıcı';
  }

  String _username(User? user) {
    final email = user?.email?.trim();
    if (email == null || email.isEmpty) {
      return '@misafir';
    }

    return '@${email.split('@').first}';
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'M';
    }

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  String _textValue(Map<String, dynamic>? data, String key) {
    final value = data?[key];
    if (value is String) {
      return value.trim();
    }

    return '';
  }

  int _intValue(Map<String, dynamic>? data, String key) {
    final value = data?[key];
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

  String _goalTitle(Map<String, dynamic>? data) {
    final title = _textValue(data, 'goalTitle');
    if (title.isNotEmpty) {
      return title;
    }

    return _textValue(data, 'goal');
  }

  String _targetText(Map<String, dynamic>? data, String key, String unit) {
    final value = _intValue(data, key);
    if (value <= 0) {
      return '-';
    }

    return '$value $unit';
  }

  Widget _buildStatCard(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : const Color(0xFF4CAF50),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFavoritesSection(
    BuildContext context,
    List<Map<String, dynamic>> favoriteRecipes,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          const ListTile(
            leading: Icon(Icons.favorite_border, color: Color(0xFF4CAF50)),
            title: Text(
              'Favorilerim',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: favoriteRecipes.isEmpty
                ? Text(
                    'Henüz favori tarif eklemedin.',
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                : Column(
                    children: favoriteRecipes.map((favorite) {
                      return _buildFavoriteRecipeTile(context, favorite);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteRecipeTile(
    BuildContext context,
    Map<String, dynamic> favorite,
  ) {
    final title = favorite['title']?.toString() ?? 'Tarif';
    final image = favorite['imageUrl']?.toString() ?? '';
    final calories = _intValue(favorite, 'calories');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(
              recipe: _profileService.favoriteRecipeToRecipe(favorite),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 52,
                    height: 52,
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
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    calories > 0 ? '$calories kcal' : 'Tarif detayı',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPill(Map<String, dynamic>? profileData) {
    final title = _goalTitle(profileData);
    final hasGoal = title.isNotEmpty;
    final label = hasGoal ? '$title Hedefi' : 'Hedef seçilmedi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGoalSection(Map<String, dynamic>? profileData) {
    final title = _goalTitle(profileData);
    final desc = _textValue(profileData, 'goalDescription');
    final hasGoal = title.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          const ListTile(
            leading: Icon(
              Icons.track_changes_outlined,
              color: Color(0xFF4CAF50),
            ),
            title: Text(
              'Hedeflerim',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: hasGoal
                ? _buildSavedGoalDetails(profileData, title, desc)
                : Text(
                    'Henüz hedef kaydetmedin.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedGoalDetails(
    Map<String, dynamic>? profileData,
    String title,
    String desc,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(color: Colors.grey.shade700)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGoalTarget(
                  'Günlük Kalori',
                  _targetText(profileData, 'dailyCalories', 'kcal'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGoalTarget(
                  'Protein',
                  _targetText(profileData, 'proteinTarget', 'g'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildGoalTarget(
                  'Karbonhidrat',
                  _targetText(profileData, 'carbohydrateTarget', 'g'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGoalTarget(
                  'Yağ',
                  _targetText(profileData, 'fatTarget', 'g'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTarget(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
      ),
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
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çıkış yapılırken bir hata oluştu')),
      );
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _signOut(context);
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildProfile(context, user, null, const [], 0);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileService.watchUserProfile(user.uid),
      builder: (context, snapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _profileService.watchFavoriteRecipes(user.uid),
          builder: (context, favoritesSnapshot) {
            return StreamBuilder<int>(
              stream: _commentService.watchUserCommentCount(user.uid),
              builder: (context, commentsSnapshot) {
                return _buildProfile(
                  context,
                  user,
                  snapshot.data?.data(),
                  favoritesSnapshot.data ?? const [],
                  commentsSnapshot.data ?? 0,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProfile(
    BuildContext context,
    User? user,
    Map<String, dynamic>? profileData,
    List<Map<String, dynamic>> favoriteRecipes,
    int commentCount,
  ) {
    final displayName = _displayName(user);
    final username = _username(user);
    final initials = _initials(displayName);
    final hasGoal = _goalTitle(profileData).isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(title: const Text('Profil'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFE8F5E9),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(username, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  _buildGoalPill(profileData),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '❤️',
                    'Favori',
                    favoriteRecipes.length.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('💬', 'Yorum', commentCount.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('🎯', 'Hedef', hasGoal ? '1' : '0'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFavoritesSection(context, favoriteRecipes),
            _buildGoalSection(profileData),
            _buildMenuItem(
              context,
              Icons.settings_outlined,
              'Ayarlar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.logout,
              'Çıkış Yap',
              isLogout: true,
              onTap: () {
                _confirmSignOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
