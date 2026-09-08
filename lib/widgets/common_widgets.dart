import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../data/mock_catalog.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AppCardTile extends StatelessWidget {
  const AppCardTile({
    super.key,
    required this.app,
    required this.onTap,
  });

  final StoreApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AsColors.surface,
      borderRadius: BorderRadius.circular(AsRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AsRadii.lg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AsRadii.lg),
            border: Border.all(color: AsColors.border),
          ),
          padding: const EdgeInsets.all(AsSpacing.md),
          child: Row(
            children: [
              AppIconImage(url: app.iconUrl, size: 64),
              const SizedBox(width: AsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AsColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.displayShort,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AsColors.muted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetaChip(categoryLabel(app.category)),
                        const SizedBox(width: 6),
                        _MetaChip(app.platform.toUpperCase()),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: AsColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class AppIconImage extends StatelessWidget {
  const AppIconImage({super.key, required this.url, this.size = 56});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConfig.resolveMedia(url);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AsRadii.md),
      child: Container(
        width: size,
        height: size,
        color: AsColors.softPrimary,
        child: resolved.isEmpty
            ? Icon(Icons.apps, color: AsColors.primaryDeep, size: size * 0.45)
            : CachedNetworkImage(
                imageUrl: resolved,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(color: AsColors.softPrimary),
                errorWidget: (_, __, ___) => Icon(
                  Icons.apps_rounded,
                  color: AsColors.primaryDeep,
                  size: size * 0.45,
                ),
              ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AsColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AsColors.muted,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AsSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AsColors.text,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(color: AsColors.muted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyStateBox extends StatelessWidget {
  const EmptyStateBox({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AsSpacing.xl),
      decoration: BoxDecoration(
        color: AsColors.surface,
        borderRadius: BorderRadius.circular(AsRadii.lg),
        border: Border.all(color: AsColors.border),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AsColors.muted, height: 1.45),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AsSpacing.md),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
