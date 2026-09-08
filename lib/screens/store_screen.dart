import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_catalog.dart';
import '../providers/store_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import '../widgets/common_widgets.dart';
import '../widgets/shimmer_widgets.dart';
import 'app_detail_screen.dart';
import 'category_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final featured = store.featured;
    final list = store.filtered;

    return Scaffold(
      body: RefreshIndicator(
        color: AsColors.primary,
        onRefresh: () => context.read<StoreProvider>().load(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const BrandMark(size: 48, radius: 12),
                        const SizedBox(width: 12),
                        const Expanded(child: BrandTitle()),
                        IconButton(
                          tooltip: 'الفئات',
                          onPressed: () => openCategoryBrowse(context),
                          icon: const Icon(Icons.category_outlined),
                        ),
                        IconButton(
                          tooltip: 'ترتيب وتصفية',
                          onPressed: () => _openSortSheet(context, store),
                          icon: const Icon(Icons.tune_rounded),
                        ),
                        if (store.usingMock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AsColors.warning.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'وضع تجريبي',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AsColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'اكتشف تطبيقات مستقلة بهدوء',
                      style: TextStyle(
                        fontSize: 15,
                        color: AsColors.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _search,
                      onChanged: store.setQuery,
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن تطبيق…',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final key in categoryLabelsAr.keys)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: ChoiceChip(
                                label: Text(categoryLabel(key)),
                                selected: store.category == key,
                                onSelected: (_) => store.setCategory(key),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (store.loading && store.apps.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const AppCardSkeleton(),
                    const SizedBox(height: 12),
                    const AppCardSkeleton(),
                    const SizedBox(height: 12),
                    const AppCardSkeleton(),
                  ]),
                ),
              )
            else if (store.error != null && store.apps.isEmpty)
              SliverFillRemaining(
                child: ErrorRetryBox(
                  message: store.error!,
                  onRetry: () => context.read<StoreProvider>().load(),
                ),
              )
            else ...[
              if (featured.isNotEmpty &&
                  store.category == 'all' &&
                  store.query.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader('مميّز'),
                        ...featured.map(
                          (app) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCardTile(
                              app: app,
                              onTap: () => _open(app.slug),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList.builder(
                  itemCount: list.isEmpty ? 1 : list.length + 1,
                  itemBuilder: (context, i) {
                    if (list.isEmpty) {
                      return const EmptyStateBox(
                        message: 'لا توجد تطبيقات تطابق بحثك حالياً.',
                      );
                    }
                    if (i == 0) {
                      return const SectionHeader('كل التطبيقات');
                    }
                    final app = list[i - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCardTile(
                        app: app,
                        onTap: () => _open(app.slug),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _open(String slug) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AppDetailScreen(slug: slug)),
    );
  }

  void _openSortSheet(BuildContext context, StoreProvider store) {
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
                  'ترتيب النتائج',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ...[
                  ('newest', 'الأحدث'),
                  ('popular', 'الأكثر شعبية'),
                  ('rating', 'الأعلى تقييمًا'),
                ].map(
                  (opt) => ListTile(
                    title: Text(opt.$2),
                    trailing: store.sort == opt.$1
                        ? const Icon(Icons.check_rounded, color: AsColors.primaryDeep)
                        : null,
                    onTap: () {
                      store.setSort(opt.$1);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
