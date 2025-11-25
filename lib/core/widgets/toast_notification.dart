import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

enum AppToastType { success, error, info, warning }

class AppToastColors {
  static Color bg(AppToastType type, ThemeData theme) {
    switch (type) {
      case AppToastType.success:
        return const Color(0xFFFFFFFF);
      case AppToastType.error:
        return const Color(0xFFFFFFFF);
      case AppToastType.info:
        return const Color(0xFFFFFFFF);
      case AppToastType.warning:
        return const Color(0xFFFFFFFF);
    }
  }

  static Color iconBg(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const Color(0xFFECFEEA);
      case AppToastType.error:
        return const Color(0xFFF8DDDB);
      case AppToastType.info:
        return const Color(0xFFDDEFF7);
      case AppToastType.warning:
        return const Color(0xFFFDF2E1);
    }
  }

  static Color fg(AppToastType type, ThemeData theme) {
    switch (type) {
      case AppToastType.success:
        return const Color(0xFF43B75D);
      case AppToastType.error:
        return const Color(0xFFEE443F);
      case AppToastType.info:
        return const Color(0xFF0095FF);
      case AppToastType.warning:
        return const Color(0xFFFFAA00);
    }
  }

  static Color strip(AppToastType type) => fg(type, ThemeData.light());
}

String _defaultToastTitle(AppToastType type) {
  switch (type) {
    case AppToastType.success:
      return 'Sukses';
    case AppToastType.error:
      return 'Kesalahan';
    case AppToastType.info:
      return 'Info';
    case AppToastType.warning:
      return 'Peringatan';
  }
}

class AppToast extends StatelessWidget {
  final String title;
  final String? message;
  final AppToastType type;
  final VoidCallback? onClose;

  const AppToast({
    super.key,
    required this.title,
    this.message,
    this.type = AppToastType.success,
    this.onClose,
  });

  IconData _icon(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return Icons.check_circle;
      case AppToastType.error:
        return Icons.error_rounded;
      case AppToastType.info:
        return Icons.info_rounded;
      case AppToastType.warning:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = AppToastColors.fg(type, theme);
    final bg = AppToastColors.bg(type, theme);
    final iconBg = AppToastColors.iconBg(type);
    final isWeb = kIsWeb;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(minHeight: isWeb ? 72 : 56),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Background area untuk icon
              Container(
                width: isWeb ? 64 : 56,
                color: iconBg,
                child: Center(
                  child: Icon(_icon(type), color: fg, size: isWeb ? 28 : 24),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isWeb ? 16 : 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: isWeb ? 15 : 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (message != null && message!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                message!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                  fontSize: isWeb ? 13 : 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: onClose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        iconSize: 18,
                        icon: Icon(Icons.close, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

OverlayEntry? _currentToastOverlay;

void showAppToast(
  BuildContext context, {
  String? title,
  String? message,
  AppToastType type = AppToastType.success,
  Duration duration = const Duration(seconds: 4),
}) {
  _currentToastOverlay?.remove();
  _currentToastOverlay = null;

  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  final resolvedTitle = (title == null || title.isEmpty)
      ? _defaultToastTitle(type)
      : title;

  overlayEntry = OverlayEntry(
    builder: (context) {
      final isWeb = kIsWeb;
      if (isWeb) {
        // Web: bottom-left corner, not full width
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = math.min(560.0, screenWidth * 0.5);
        return Positioned(
          left: 16,
          bottom: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: AppToast(
                  title: resolvedTitle,
                  message: message,
                  type: type,
                  onClose: () {
                    overlayEntry.remove();
                    _currentToastOverlay = null;
                  },
                ),
              ),
            ),
          ),
        );
      } else {
        // Mobile/Desktop app: top, full width with margins
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -30 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: AppToast(
                title: resolvedTitle,
                message: message,
                type: type,
                onClose: () {
                  overlayEntry.remove();
                  _currentToastOverlay = null;
                },
              ),
            ),
          ),
        );
      }
    },
  );

  _currentToastOverlay = overlayEntry;
  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    if (_currentToastOverlay == overlayEntry) {
      overlayEntry.remove();
      _currentToastOverlay = null;
    }
  });
}
