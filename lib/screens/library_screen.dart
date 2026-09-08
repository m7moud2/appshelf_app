import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'app_detail_screen.dart';
import 'auth_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _maybeLoad() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      await context.read<LibraryProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lib = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مكتبتي'),
        bottom: auth.isLoggedIn
            ? TabBar(
                controller: _tabs,
                labelColor: AsColors.primaryDeep,
                unselectedLabelColor: AsColors.muted,
                indicatorColor: AsColors.primary,
                tabs: [
                  Tab(text: 'المفضلة (${lib.favorites.length})'),
                  Tab(text: 'المثبّتة (${lib.installed.length})'),
                ],
              )
            : null,
      ),
      body: !auth.isLoggedIn
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: EmptyStateBox(
                message:
                    'سجّل الدخول لعرض المفضلة والتطبيقات التي ثبّتها من المتجر.',
                actionLabel: 'دخول / تسجيل',
                onAction: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                  if (mounted) _maybeLoad();
                },
              ),
            )
          : lib.loading && lib.favorites.isEmpty && lib.installed.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _list(
                      apps: lib.favorites,
                      empty: 'لا مفضلات بعد — أضف من صفحة التطبيق.',
                    ),
                    _list(
                      apps: lib.installed,
                      empty: 'لا تطبيقات مثبّتة بعد — جرّب زر التثبيت.',
                    ),
                  ],
                ),
    );
  }

  Widget _list({required List<StoreApp> apps, required String empty}) {
    if (apps.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<LibraryProvider>().refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [EmptyStateBox(message: empty)],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<LibraryProvider>().refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: apps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final app = apps[i];
          return AppCardTile(
            app: app,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AppDetailScreen(slug: app.slug),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
