import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56, this.radius = 14});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AsColors.primary, AsColors.primaryDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: AsColors.primaryDeep.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.apps_rounded,
          color: Colors.white.withOpacity(0.95),
          size: size * 0.48,
        ),
      ),
    );
  }
}

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رف التطبيقات',
          style: TextStyle(
            fontSize: compact ? 18 : 28,
            fontWeight: FontWeight.w800,
            color: AsColors.primaryDeep,
            height: 1.15,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            'AppShelf',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AsColors.muted.withOpacity(0.9),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );
  }
}
