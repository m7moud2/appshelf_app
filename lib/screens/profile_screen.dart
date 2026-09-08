import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../providers/store_provider.dart';
import '../services/api_client.dart';
import '../services/notification_service.dart';
import '../services/update_checker.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import 'auth_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiController.text = ApiConfig.baseUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    final checker = UpdateChecker(context.read<ApiClient>());
    final result = await checker.checkSelfUpdate(currentVersion: '1.0.0');
    if (!mounted || !result.updateAvailable) return;
    await NotificationService.instance.showAppUpdateAvailable(
      result.storeVersion ?? '',
    );
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تحديث متاح'),
        content: Text(
          'إصدار جديد ${result.storeVersion} متوفر على المتجر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لاحقًا'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (result.storeUrl != null) {
                launchUrl(
                  Uri.parse(result.storeUrl!),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: const Text('تحميل'),
          ),
        ],
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
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthProvider>().bootstrap();
          if (context.read<AuthProvider>().isLoggedIn) {
            await context.read<LibraryProvider>().refresh(requireAuth: false);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
          const Row(
            children: [
              BrandMark(size: 52, radius: 14),
              SizedBox(width: 12),
              Expanded(child: BrandTitle(compact: true)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AsColors.softPrimary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AsRadii.md),
              border: Border.all(color: AsColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'هذا التطبيق مدرج على متجر الويب',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  ApiConfig.storeListingUrl,
                  style: const TextStyle(color: AsColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(ApiConfig.storeListingUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('فتح الصفحة'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Share.share(
                          'حمّل عميل رف التطبيقات من المتجر:\n${ApiConfig.storeListingUrl}',
                        );
                      },
                      icon: const Icon(Icons.ios_share_rounded, size: 18),
                      label: const Text('مشاركة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (user == null)
            Emptyish(
              message: 'أنت زائر الآن. سجّل الدخول لإدارة المفضلة والمكتبة.',
              actionLabel: 'دخول / تسجيل',
              onAction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              },
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AsColors.surface,
                borderRadius: BorderRadius.circular(AsRadii.lg),
                border: Border.all(color: AsColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email, style: const TextStyle(color: AsColors.muted)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip(_roleLabel(user.role)),
                      if (user.isDeveloper)
                        _chip(
                          user.subscriptionActive
                              ? 'اشتراك نشط'
                              : 'بدون اشتراك',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout_rounded, color: AsColors.danger),
              title: const Text('تسجيل الخروج'),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  context.read<LibraryProvider>().clear();
                }
              },
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'إعدادات الاتصال (للمختبرين)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiController,
            decoration: const InputDecoration(
              labelText: 'عنوان API',
              hintText: 'http://192.168.x.x:3000',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilledButton(
                onPressed: () async {
                  await ApiConfig.setOverride(_apiController.text);
                  if (!context.mounted) return;
                  await context.read<StoreProvider>().load();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حفظ العنوان: ${ApiConfig.baseUrl}'),
                    ),
                  );
                  setState(() {});
                },
                child: const Text('حفظ'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  await ApiConfig.setOverride(null);
                  _apiController.text = ApiConfig.baseUrl;
                  if (!context.mounted) return;
                  await context.read<StoreProvider>().load();
                  setState(() {});
                },
                child: const Text('إعادة للافتراضي'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('تجربة إشعار محلي'),
            subtitle: const Text('تنبيه خفيف عن تحديثات المتجر'),
            onTap: () => NotificationService.instance.showCatalogTip(),
          ),
        ],
        ),
      ),
    );
  }

  static String _roleLabel(String role) {
    switch (role) {
      case 'developer':
        return 'مطوّر';
      case 'admin':
        return 'مدير';
      default:
        return 'مستخدم';
    }
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AsColors.softPrimary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AsColors.primaryDeep,
          fontSize: 12,
        ),
      ),
    );
  }
}

class Emptyish extends StatelessWidget {
  const Emptyish({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AsColors.surface,
        borderRadius: BorderRadius.circular(AsRadii.lg),
        border: Border.all(color: AsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: const TextStyle(color: AsColors.muted, height: 1.45)),
          const SizedBox(height: 12),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
