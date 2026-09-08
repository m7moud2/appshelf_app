import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_catalog.dart';
import '../providers/store_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/shimmer_widgets.dart';
import 'app_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final apps = store.apps
        .where((a) => a.category == categoryId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryLabel(categoryId)),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<StoreProvider>().load(),
        child: store.loading && store.apps.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: const [
                  AppCardSkeleton(),
                  SizedBox(height: 12),
                  AppCardSkeleton(),
                ],
              )
            : apps.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      EmptyStateBox(
                        message: 'لا تطبيقات في فئة ${categoryLabel(categoryId)} حالياً.',
                      ),
                    ],
                  )
                : ListView.separated(
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
      ),
    );
  }
}

void openCategoryBrowse(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تصفّح حسب الفئة',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in categoryLabelsAr.keys)
                    if (key != 'all')
                      ActionChip(
                        label: Text(categoryLabel(key)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryScreen(categoryId: key),
                            ),
                          );
                        },
                      ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
