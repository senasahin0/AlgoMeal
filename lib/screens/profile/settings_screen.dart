import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/user_profile_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingItem(
              context,
              Icons.person_outline,
              'Hesap Bilgileri',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
                );
              },
            ),
            _buildSettingItem(
              context,
              Icons.dark_mode_outlined,
              'Koyu Tema (Yakında)',
              onTap: () {
                _showComingSoon(context, 'Koyu tema');
              },
            ),
            _buildSettingItem(
              context,
              Icons.notifications_outlined,
              'Bildirimler (Yakında)',
              onTap: () {
                _showComingSoon(context, 'Bildirimler');
              },
            ),
            if (user == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Hesap bilgilerini görmek için giriş yapmalısın.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
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
        leading: Icon(icon, color: const Color(0xFF4CAF50)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title yakında aktif olacak')));
  }
}

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  static final UserProfileService _profileService = UserProfileService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F9F7),
        appBar: AppBar(title: const Text('Hesap Bilgileri')),
        body: Center(
          child: Text(
            'Hesap bilgilerini görmek için giriş yapmalısın.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileService.watchUserProfile(user.uid),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9F7),
          appBar: AppBar(title: const Text('Hesap Bilgileri')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Text(
                          _initials(_displayName(user, data)),
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _displayName(user, data),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'E-posta yok',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoTile('Ad Soyad', _displayName(user, data)),
                _buildInfoTile('Kullanıcı Adı', _username(user)),
                _buildInfoTile('E-posta', user.email ?? '-'),
                _buildInfoTile('Hedef', _goalTitle(data)),
                _buildInfoTile(
                  'Günlük Kalori',
                  _targetText(data, 'dailyCalories', 'kcal'),
                ),
                _buildInfoTile(
                  'Protein Hedefi',
                  _targetText(data, 'proteinTarget', 'g'),
                ),
                _buildInfoTile(
                  'Karbonhidrat Hedefi',
                  _targetText(data, 'carbohydrateTarget', 'g'),
                ),
                _buildInfoTile(
                  'Yağ Hedefi',
                  _targetText(data, 'fatTarget', 'g'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(User user, Map<String, dynamic>? data) {
    final firestoreName = data?['name'];
    if (firestoreName is String && firestoreName.trim().isNotEmpty) {
      return firestoreName.trim();
    }

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Kullanıcı';
  }

  String _username(User user) {
    final email = user.email?.trim();
    if (email == null || email.isEmpty) {
      return '@kullanici';
    }

    return '@${email.split('@').first}';
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

    return 'Hedef seçilmedi';
  }

  String _targetText(Map<String, dynamic>? data, String key, String unit) {
    final value = _intValue(data?[key]);
    if (value <= 0) {
      return '-';
    }

    return '$value $unit';
  }

  int _intValue(dynamic value) {
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

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'K';
    }

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
