import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  static const prefsKey = 'appshelf_onboarding_done_v1';

  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) == true;
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    (
      title: 'متجر هادئ للتطبيقات المستقلة',
      body: 'تصفّح تطبيقات عربية وهادئة بدون ضوضاء المتاجر الكبيرة.',
      icon: Icons.storefront_rounded,
    ),
    (
      title: 'مفضلتك ومكتبتك',
      body: 'احفظ ما تحب وثبّت ما تحتاجه — كل شيء في مكان واحد.',
      icon: Icons.favorite_rounded,
    ),
    (
      title: 'دخول سريع',
      body: 'تابع مع Google أو Apple، أو استخدم حسابًا تجريبيًا للتجربة فورًا.',
      icon: Icons.lock_open_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingScreen.markDone();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const BrandMark(size: 56, radius: 16),
            const SizedBox(height: 8),
            const BrandTitle(compact: true),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 72, color: AsColors.primary),
                        const SizedBox(height: 28),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AsColors.muted,
                            height: 1.55,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final on = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: on ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: on ? AsColors.primary : AsColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: const Text('تخطّي'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_index >= _pages.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: Text(
                      _index >= _pages.length - 1 ? 'ابدأ' : 'التالي',
                    ),
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
