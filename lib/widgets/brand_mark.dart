import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        boxShadow: [
          BoxShadow(
            color: AsColors.primaryDeep.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SvgPicture.asset(
        'assets/brand/appshelf-mark.svg',
        width: size,
        height: size,
        fit: BoxFit.cover,
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
