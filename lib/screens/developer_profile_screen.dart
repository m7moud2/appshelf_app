import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../services/api_client.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/shimmer_widgets.dart';
import 'app_detail_screen.dart';

class DeveloperProfileScreen extends StatefulWidget {
  const DeveloperProfileScreen({super.key, required this.slug});

  final String slug;

  @override
  State<DeveloperProfileScreen> createState() => _DeveloperProfileScreenState();
}

class _DeveloperProfileScreenState extends State<DeveloperProfileScreen> {
  DeveloperProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile =
          await context.read<ApiClient>().fetchDeveloperProfile(widget.slug);
      if (!mounted) return;
      if (profile == null) {
        setState(() {
          _error = 'المطوّر غير موجود';
          _loading = false;
        });
        return;
      }
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذّر تحميل الملف';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_profile?.name ?? 'المطوّر')),
      body: _loading
          ? const AppDetailSkeleton()
          : _error != null
              ? ErrorRetryBox(message: _error!, onRetry: _load)
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final p = _profile!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AsColors.softPrimary,
                child: Icon(Icons.person, color: AsColors.primaryDeep, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (p.verified)
                      const Text(
                        'مطوّر موثّق',
                        style: TextStyle(
                          color: AsColors.primaryDeep,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (p.country != null)
                      Text(p.country!, style: const TextStyle(color: AsColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          if (p.bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(p.bio, style: const TextStyle(height: 1.5)),
          ],
          if (p.website != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(p.website!),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.language_rounded),
              label: const Text('الموقع'),
            ),
          ],
          const SizedBox(height: 20),
          SectionHeader('تطبيقات الناشر', subtitle: '${p.apps.length}'),
          ...p.apps.map(
            (app) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCardTile(
                app: app,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AppDetailScreen(slug: app.slug),
                    ),
                  );
                },
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              launchUrl(
                Uri.parse('${ApiConfig.baseUrl}/developers/${p.slug}'),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('فتح على الويب'),
          ),
        ],
      ),
    );
  }
}
