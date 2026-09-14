import 'package:flutter/material.dart';

import 'shimmer_widgets.dart';

/// Catches synchronous build errors in the store tab and shows retry UI.
class StoreErrorBoundary extends StatefulWidget {
  const StoreErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  State<StoreErrorBoundary> createState() => _StoreErrorBoundaryState();
}

class _StoreErrorBoundaryState extends State<StoreErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorRetryBox(
            message: 'تعذّر عرض المتجر',
            onRetry: () => setState(() => _error = null),
          ),
        ),
      );
    }
    return _StoreErrorBoundaryScope(
      onError: (error) {
        if (mounted) setState(() => _error = error);
      },
      child: widget.child,
    );
  }
}

class _StoreErrorBoundaryScope extends StatelessWidget {
  const _StoreErrorBoundaryScope({
    required this.onError,
    required this.child,
  });

  final ValueChanged<Object> onError;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          onError(e);
          return const SizedBox.shrink();
        }
      },
    );
  }
}
