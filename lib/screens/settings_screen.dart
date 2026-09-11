import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiController =
      TextEditingController(text: ApiConfig.baseUrl);
  bool _saving = false;

  Future<void> _applyApi(String? url) async {
    setState(() => _saving = true);
    await ApiConfig.setOverride(url);
    if (!mounted) return;
    setState(() {
      _apiController.text = ApiConfig.baseUrl;
      _saving = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          url == null
              ? 'تمت إعادة الضبط — أعد تشغيل التطبيق أو حدّث المتجر'
              : 'تم حفظ عنوان الخادم',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Center(child: BrandMark(size: 56)),
          const SizedBox(height: 12),
          const Text(
            'عن التطبيق',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('رف التطبيقات'),
            subtitle: Text(
              'الإصدار ${ApiConfig.appVersion} · ${ApiConfig.baseUrl}',
            ),
          ),
          const Divider(),
          Text(
            'عنوان الخادم (API)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiController,
            decoration: const InputDecoration(
              hintText: 'https://appshelf-nine.vercel.app',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _saving
                    ? null
                    : () => _applyApi(_apiController.text.trim()),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('حفظ'),
              ),
              OutlinedButton(
                onPressed: _saving ? null : () => _applyApi(ApiConfig.productionBaseUrl),
                child: const Text('الإنتاج (Vercel)'),
              ),
              TextButton(
                onPressed: _saving ? null : () => _applyApi(null),
                child: const Text('افتراضي'),
              ),
            ],
          ),
          if (ApiConfig.isUsingProduction)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'متصل بالخادم العام',
                style: TextStyle(
                  color: AsColors.primaryDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const Divider(height: 32),
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
