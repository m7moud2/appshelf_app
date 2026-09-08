import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_catalog.dart';
import '../providers/store_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import '../widgets/common_widgets.dart';
import 'app_detail_screen.dart';

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
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
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
}
