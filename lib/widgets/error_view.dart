import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';


class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
  });

  IconData _getIcon() {
    if (icon != null) return icon!;

    final lower = message.toLowerCase();
    if (lower.contains('internet') || lower.contains('connection')) {
      return Icons.wifi_off_rounded;
    }
    if (lower.contains('server') || lower.contains('timed out')) {
      return Icons.cloud_off_rounded;
    }
    if (lower.contains('parse') || lower.contains('invalid')) {
      return Icons.data_object_rounded;
    }
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title ?? 'Oops!',
              style: AppTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}