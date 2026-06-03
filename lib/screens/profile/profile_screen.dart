import 'package:flutter/material.dart';

import 'settings_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  Widget _buildStatCard(
  String emoji,
  String title,
  String value,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
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
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? Colors.red
            : const Color(0xFF4CAF50),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout
              ? Colors.red
              : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),

      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // PROFİL KARTI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                    child: const Text(
                      "BI",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Büşra Işık",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "@busra",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "🎯 Kilo Verme Hedefi",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
   const SizedBox(height: 20),

Row(
  children: [

    Expanded(
      child: _buildStatCard(
        "❤️",
        "Favori",
        "0",
      ),
    ),

    const SizedBox(width: 8),

    Expanded(
      child: _buildStatCard(
        "📅",
        "Plan",
        "0",
      ),
    ),

    const SizedBox(width: 8),

    Expanded(
      child: _buildStatCard(
        "💬",
        "Yorum",
        "0",
      ),
    ),

    const SizedBox(width: 8),

    Expanded(
      child: _buildStatCard(
        "🎯",
        "Hedef",
        "1",
      ),
    ),
  ],
),        
const SizedBox(height: 24),

_buildMenuItem(
  context,
  Icons.favorite_border,
  "Favorilerim",
),

_buildMenuItem(
  context,
  Icons.calendar_month_outlined,
  "Haftalık Planlarım",
),

_buildMenuItem(
  context,
  Icons.track_changes_outlined,
  "Hedeflerim",
),

_buildMenuItem(
  context,
  Icons.settings_outlined,
  "Ayarlar",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  },
),

_buildMenuItem(
  context,
  Icons.logout,
  "Çıkış Yap",
  isLogout: true,
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text(
          "Çıkış yapmak istediğinize emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text("Çıkış Yap"),
          ),
        ],
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