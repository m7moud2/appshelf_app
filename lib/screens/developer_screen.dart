import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../data/mock_catalog.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'auth_screen.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  List<StoreApp> _apps = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isDeveloper) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apps = await context.read<ApiClient>().myApps();
      if (!mounted) return;
      setState(() {
        _apps = apps;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('ApiException: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (!auth.isLoggedIn || !auth.isDeveloper) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة المطوّر')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: EmptyStateBox(
            message:
                'هذه المنطقة للمطوّرين. سجّل بحساب مطوّر أو استخدم الحساب التجريبي.',
            actionLabel: 'دخول كمطوّر',
            onAction: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
              if (mounted) _load();
            },
          ),
        ),
      );
    }

    final status = user?.developerStatus ?? 'incomplete';
    final statusLabel = developerStatusLabels[status] ?? status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المطوّر'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _StatusBanner(
              statusLabel: statusLabel,
              subscriptionActive: user?.subscriptionActive == true,
            ),
            const SizedBox(height: 20),
            const SectionHeader(
              'تطبيقاتي',
              subtitle: 'إدارة التفاصيل الكاملة من لوحة الويب حالياً.',
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              EmptyStateBox(message: _error!)
            else if (_apps.isEmpty)
              const EmptyStateBox(
                message: 'لا تطبيقات بعد. أضف أول تطبيق من لوحة الويب.',
              )
            else
              ..._apps.map((app) => _DevAppRow(app: app)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                launchUrl(
                  Uri.parse('${ApiConfig.baseUrl}/dashboard'),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(Icons.desktop_windows_outlined),
              label: const Text('فتح لوحة المطوّر على الويب'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.statusLabel,
    required this.subscriptionActive,
  });

  final String statusLabel;
  final bool subscriptionActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AsColors.softPrimary.withOpacity(0.55),
        borderRadius: BorderRadius.circular(AsRadii.lg),
        border: Border.all(color: AsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حالة الحساب',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            statusLabel,
            style: const TextStyle(
              color: AsColors.primaryDeep,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subscriptionActive
                ? 'الاشتراك فعّال — يمكنك إدارة تطبيقاتك من الويب.'
                : 'فعّل الاشتراك من موقع AppShelf لمتابعة النشر الكامل.',
            style: const TextStyle(color: AsColors.muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              launchUrl(
                Uri.parse('${ApiConfig.baseUrl}/dashboard/subscribe'),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('فتح الاشتراك على الويب'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              launchUrl(
                Uri.parse('${ApiConfig.baseUrl}/dashboard/onboarding'),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.checklist_rounded, size: 18),
            label: const Text('إكمال تجهيز الناشر'),
          ),
        ],
      ),
    );
  }
}

class _DevAppRow extends StatelessWidget {
  const _DevAppRow({required this.app});
  final StoreApp app;

  @override
  Widget build(BuildContext context) {
    final statusAr = switch (app.status) {
      'published' => 'منشور',
      'pending' => 'قيد المراجعة',
      _ => app.status,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AsColors.surface,
          borderRadius: BorderRadius.circular(AsRadii.lg),
          border: Border.all(color: AsColors.border),
        ),
        child: Row(
          children: [
            AppIconImage(url: app.iconUrl, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    statusAr,
                    style: const TextStyle(color: AsColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
