import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'developer_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'store_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final destinations = <_Dest>[
      const _Dest(Icons.storefront_rounded, 'المتجر', StoreScreen()),
      const _Dest(Icons.bookmarks_rounded, 'مكتبتي', LibraryScreen()),
      if (auth.isDeveloper)
        const _Dest(
          Icons.dashboard_customize_rounded,
          'لوحة المطوّر',
          DeveloperScreen(),
        ),
      const _Dest(Icons.person_rounded, 'حسابي', ProfileScreen()),
    ];

    final safeIndex =
        destinations.isEmpty ? 0 : _index.clamp(0, destinations.length - 1);
    if (safeIndex != _index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _index = safeIndex);
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: destinations.map((d) => d.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon, color: AsColors.muted),
              selectedIcon: Icon(d.icon, color: AsColors.primaryDeep),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Dest {
  const _Dest(this.icon, this.label, this.page);
  final IconData icon;
  final String label;
  final Widget page;
}
