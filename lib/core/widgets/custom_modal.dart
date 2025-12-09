import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool showCloseButton;
  final Widget? customIcon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomModal({
    Key? key,
    required this.title,
    required this.message,
    this.primaryButtonText = 'OK',
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.showCloseButton = true,
    this.customIcon,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    String primaryButtonText = 'OK',
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showCloseButton = true,
    Widget? customIcon,
    Color? backgroundColor,
    Color? textColor,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useRootNavigator = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? const Color(0x52000000),
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return CustomModal(
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          onPrimaryPressed: onPrimaryPressed,
          onSecondaryPressed: onSecondaryPressed,
          showCloseButton: showCloseButton,
          customIcon: customIcon,
          backgroundColor: backgroundColor,
          textColor: textColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      backgroundColor: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            if (customIcon != null) ...[
              ?customIcon,
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                color: textColor ?? theme.textTheme.headlineSmall?.color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color:
                    textColor?.withOpacity(0.8) ??
                    theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: onPrimaryPressed ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE443F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      primaryButtonText,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (secondaryButtonText != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton(
                      onPressed:
                          onSecondaryPressed ?? () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color:
                              textColor?.withOpacity(0.5) ?? theme.dividerColor,
                        ),
                      ),
                      child: Text(
                        secondaryButtonText!,
                        style: TextStyle(
                          color: textColor ?? theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
