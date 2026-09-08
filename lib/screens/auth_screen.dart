import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialSignup = false});

  final bool initialSignup;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  String _role = 'user';
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialSignup ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  bool get _preferApple {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الحساب')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Row(
            children: [
              BrandMark(size: 44, radius: 12),
              SizedBox(width: 12),
              BrandTitle(compact: true),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'ادخل لفتح المفضلة والمكتبة ولوحة المطوّر.',
            style: TextStyle(color: AsColors.muted),
          ),
          const SizedBox(height: 16),
          if (auth.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AsColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AsRadii.sm),
              ),
              child: Text(
                auth.error!,
                style: const TextStyle(color: AsColors.danger),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_preferApple) ...[
            _oauthButton(
              label: 'المتابعة مع Apple',
              icon: Icons.apple,
              filled: true,
              onPressed: auth.loading ? null : () => _oauthApple(),
            ),
            const SizedBox(height: 10),
            _oauthButton(
              label: 'المتابعة مع Google',
              icon: Icons.g_mobiledata_rounded,
              onPressed: auth.loading ? null : () => _oauthGoogle(),
            ),
          ] else ...[
            _oauthButton(
              label: 'المتابعة مع Google',
              icon: Icons.g_mobiledata_rounded,
              filled: true,
              onPressed: auth.loading ? null : () => _oauthGoogle(),
            ),
            const SizedBox(height: 10),
            if (auth.oauthService.showAppleButton)
              _oauthButton(
                label: 'المتابعة مع Apple',
                icon: Icons.apple,
                onPressed: auth.loading ? null : () => _oauthApple(),
              ),
          ],
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('أو بالبريد', style: TextStyle(color: AsColors.muted)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AsColors.surface,
              borderRadius: BorderRadius.circular(AsRadii.md),
              border: Border.all(color: AsColors.border),
            ),
            child: TabBar(
              controller: _tabs,
              labelColor: AsColors.primaryDeep,
              unselectedLabelColor: AsColors.muted,
              indicatorColor: AsColors.primary,
              tabs: const [
                Tab(text: 'دخول'),
                Tab(text: 'تسجيل'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _tabs,
            builder: (context, _) {
              final signup = _tabs.index == 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (signup) ...[
                    TextField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'الاسم'),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'user', label: Text('مستخدم')),
                        ButtonSegment(
                          value: 'developer',
                          label: Text('مطوّر'),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: (s) =>
                          setState(() => _role = s.first),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: auth.loading
                        ? null
                        : () => signup ? _signup() : _login(),
                    child: auth.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(signup ? 'إنشاء حساب' : 'دخول'),
                  ),
                  if (!signup)
                    TextButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse('${ApiConfig.baseUrl}/forgot-password'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: const Text('نسيت كلمة المرور؟'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _oauthButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool filled = false,
  }) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
    if (filled) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AsColors.text,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: onPressed,
        child: child,
      );
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      onPressed: onPressed,
      child: child,
    );
  }

  Future<void> _afterAuth(bool ok) async {
    if (!mounted || !ok) return;
    await context.read<LibraryProvider>().refresh(requireAuth: false);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _oauthGoogle() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    await _afterAuth(await auth.signInWithGoogle());
  }

  Future<void> _oauthApple() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    await _afterAuth(await auth.signInWithApple());
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    await _afterAuth(await auth.login(_email.text, _password.text));
  }

  Future<void> _signup() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    await _afterAuth(
      await auth.signup(
        email: _email.text,
        password: _password.text,
        name: _name.text,
        role: _role,
      ),
    );
  }
}
