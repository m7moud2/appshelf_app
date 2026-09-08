import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Text(
            'عن التطبيق',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('رف التطبيقات'),
            subtitle: Text('الإصدار 1.0.0 · ${ApiConfig.baseUrl}'),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: const Text('الشروط والأحكام'),
            onTap: () => launchUrl(
              Uri.parse('${ApiConfig.baseUrl}/terms'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('سياسة الخصوصية'),
            onTap: () => launchUrl(
              Uri.parse('${ApiConfig.baseUrl}/privacy'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('دليل الاستخدام'),
            onTap: () => launchUrl(
              Uri.parse('${ApiConfig.baseUrl}/guide'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_reset_rounded),
            title: const Text('نسيت كلمة المرور؟'),
            subtitle: const Text('يفتح صفحة الويب'),
            onTap: () => launchUrl(
              Uri.parse('${ApiConfig.baseUrl}/forgot-password'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}
