import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),

      appBar: AppBar(
        title: const Text("Ayarlar"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _buildSettingItem(
              Icons.person_outline,
              "Hesap Bilgileri",
            ),

            _buildSettingItem(
              Icons.track_changes_outlined,
              "Hedefler",
            ),

            _buildSettingItem(
              Icons.dark_mode_outlined,
              "Koyu Tema (Yakında)",
            ),

            _buildSettingItem(
              Icons.notifications_outlined,
              "Bildirimler (Yakında)",
            ),

            _buildSettingItem(
              Icons.info_outline,
              "Hakkında",
            ),

            _buildSettingItem(
              Icons.mail_outline,
              "İletişim",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
  ) {
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
          color: const Color(0xFF4CAF50),
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {},
      ),
    );
  }
}