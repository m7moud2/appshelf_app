import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../data/mock_catalog.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/shimmer_widgets.dart';
import 'auth_screen.dart';
import 'developer_profile_screen.dart';

class AppDetailScreen extends StatefulWidget {
  const AppDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  State<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends State<AppDetailScreen> {
  AppDetailBundle? _bundle;
  bool _loading = true;
  String? _error;
  bool _busy = false;
  List<Map<String, dynamic>> _reviews = [];
  List<StoreApp> _related = [];
  int _rating = 5;
  final _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final bundle = await api.fetchAppDetail(widget.slug);
      final reviews = await api.fetchReviews(bundle.app.id);
      final related = await api.fetchRelatedApps(bundle.app.id);
      if (!mounted) return;
      final lib = context.read<LibraryProvider>();
      setState(() {
        _bundle = bundle;
        _reviews = reviews;
        _related = related;
        _loading = false;
      });
      if (bundle.library.favorited) {
        lib.favoriteIds.add(bundle.app.id);
      }
      if (bundle.library.installed) {
        lib.installedIds.add(bundle.app.id);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذّر فتح صفحة التطبيق';
        _loading = false;
      });
    }
  }

  String _absoluteDownload(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiConfig.baseUrl}$url';
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_bundle?.app.displayName ?? 'التطبيق'),
        actions: [
          if (_bundle != null) ...[
            IconButton(
              tooltip: 'مشاركة',
              onPressed: () {
                final app = _bundle!.app;
                Share.share(
                  '${app.displayName}\n${ApiConfig.baseUrl}/apps/${app.slug}',
                );
              },
              icon: const Icon(Icons.ios_share_rounded),
            ),
            IconButton(
              tooltip: 'مفضلة',
              onPressed: _busy ? null : () => _toggleFavorite(auth),
              icon: Icon(
                lib.isFavorite(_bundle!.app.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: lib.isFavorite(_bundle!.app.id)
                    ? AsColors.danger
                    : AsColors.muted,
              ),
            ),
          ],
        ],
      ),
      body: _loading
          ? const AppDetailSkeleton()
          : _error != null
              ? ErrorRetryBox(message: _error!, onRetry: _load)
              : _buildBody(lib, auth),
      bottomNavigationBar: _bundle == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: _busy ? null : _install,
                  icon: const Icon(Icons.download_rounded),
                  label: Text(
                    lib.isInstalled(_bundle!.app.id)
                        ? 'فتح رابط التحميل'
                        : 'تثبيت / تحميل',
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(LibraryProvider lib, AuthProvider auth) {
    final app = _bundle!.app;
    final publisher = _bundle!.publisher;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconImage(url: app.iconUrl, size: 88),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: publisher.slug != null && publisher.slug!.isNotEmpty
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DeveloperProfileScreen(
                                  slug: publisher.slug!,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      publisher.name,
                      style: const TextStyle(
                        color: AsColors.primaryDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _pill(categoryLabel(app.category)),
                      _pill(app.platform.toUpperCase()),
                      _pill('v${app.version}'),
                      _pill(app.sizeLabel),
                      if (app.downloadsPlaceholder > 0)
                        _pill('${app.downloadsPlaceholder} تحميل'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          app.displayShort,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AsColors.muted,
          ),
        ),
        if (app.screenshots.isNotEmpty) ...[
          const SizedBox(height: 22),
          const SectionHeader('لقطات الشاشة'),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: app.screenshots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final url = ApiConfig.resolveMedia(app.screenshots[i]);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AsRadii.md),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AsColors.softPrimary,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 22),
        const SectionHeader('عن التطبيق'),
        Text(
          app.displayDescription,
          style: const TextStyle(height: 1.55, fontSize: 15),
        ),
        if (app.displayWhatsNew.isNotEmpty) ...[
          const SizedBox(height: 22),
          const SectionHeader('ما الجديد'),
          Text(
            app.displayWhatsNew,
            style: const TextStyle(height: 1.5, color: AsColors.muted),
          ),
        ],
        const SizedBox(height: 22),
        SectionHeader(
          'التقييمات',
          subtitle: _reviews.isEmpty
              ? 'كن أول من يقيّم'
              : '${_reviews.length} تقييم',
        ),
        if (auth.isLoggedIn) ...[
          Row(
            children: [
              const Text('تقييمك:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _rating,
                items: [5, 4, 3, 2, 1]
                    .map(
                      (n) => DropdownMenuItem(
                        value: n,
                        child: Text('$n ★'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _rating = v ?? 5),
              ),
            ],
          ),
          TextField(
            controller: _comment,
            decoration: const InputDecoration(
              hintText: 'تعليق اختياري…',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _submitReview,
            child: const Text('إرسال التقييم'),
          ),
          const SizedBox(height: 12),
        ] else
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            child: const Text('سجّل الدخول للتقييم'),
          ),
        ..._reviews.take(8).map((r) {
          final stars = int.tryParse('${r['rating']}') ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AsColors.surface,
                borderRadius: BorderRadius.circular(AsRadii.md),
                border: Border.all(color: AsColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${r['userName'] ?? 'مستخدم'} · ${'★' * stars}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if ((r['comment']?.toString() ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('${r['comment']}'),
                  ],
                ],
              ),
            ),
          );
        }),
        if (_related.isNotEmpty) ...[
          const SizedBox(height: 22),
          const SectionHeader('تطبيقات مشابهة'),
          ..._related.take(4).map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCardTile(
                    app: a,
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AppDetailScreen(slug: a.slug),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AsColors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AsColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AsColors.muted,
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _busy = true);
    final api = context.read<ApiClient>();
    final appId = _bundle!.app.id;
    try {
      await api.submitReview(
        appId: appId,
        rating: _rating,
        comment: _comment.text,
      );
      _comment.clear();
      final reviews = await api.fetchReviews(appId);
      if (!mounted) return;
      setState(() => _reviews = reviews);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ تقييمك')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleFavorite(AuthProvider auth) async {
    if (!auth.isLoggedIn) {
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      final favorited = await context
          .read<LibraryProvider>()
          .toggleFavorite(_bundle!.app.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(favorited ? 'أُضيف للمفضلة' : 'أُزيل من المفضلة'),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _install() async {
    setState(() => _busy = true);
    try {
      final result =
          await context.read<ApiClient>().install(_bundle!.app.id);
      if (!mounted) return;
      context
          .read<LibraryProvider>()
          .markInstalled(_bundle!.app.id, _bundle!.app);
      final url = _absoluteDownload(
        result.downloadUrl.isNotEmpty
            ? result.downloadUrl
            : _bundle!.app.downloadUrl,
      );
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on ApiException catch (e) {
      final url = _absoluteDownload(_bundle!.app.downloadUrl);
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          context
              .read<LibraryProvider>()
              .markInstalled(_bundle!.app.id, _bundle!.app);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      final uri = Uri.tryParse(_absoluteDownload(_bundle!.app.downloadUrl));
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
