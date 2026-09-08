import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _ctrl.value * 2, 0),
              end: Alignment(1 + _ctrl.value * 2, 0),
              colors: const [
                AsColors.softPrimary,
                Color(0xFFE8EFED),
                AsColors.softPrimary,
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppCardSkeleton extends StatelessWidget {
  const AppCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AsSpacing.md),
      decoration: BoxDecoration(
        color: AsColors.surface,
        borderRadius: BorderRadius.circular(AsRadii.lg),
        border: Border.all(color: AsColors.border),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 64, height: 64, borderRadius: 14),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 14, borderRadius: 6),
                SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 12, borderRadius: 6),
                SizedBox(height: 6),
                ShimmerBox(width: 180, height: 12, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppDetailSkeleton extends StatelessWidget {
  const AppDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Row(
          children: [
            ShimmerBox(width: 88, height: 88, borderRadius: 18),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 160, height: 18, borderRadius: 6),
                  SizedBox(height: 10),
                  ShimmerBox(width: 100, height: 14, borderRadius: 6),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
        SizedBox(height: 8),
        ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
        SizedBox(height: 8),
        ShimmerBox(width: 220, height: 14, borderRadius: 6),
        SizedBox(height: 24),
        ShimmerBox(width: double.infinity, height: 180, borderRadius: 16),
      ],
    );
  }
}

class ErrorRetryBox extends StatelessWidget {
  const ErrorRetryBox({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: AsColors.muted.withOpacity(0.7)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AsColors.muted, height: 1.45),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
