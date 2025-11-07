import 'package:flutter/material.dart';

class ErrorModal extends StatelessWidget {
  final String message;
  final String? title;
  final String buttonText;
  final VoidCallback? onClose;

  const ErrorModal({
    Key? key,
    required this.message,
    this.title = 'Error',
    this.buttonText = 'OK',
    this.onClose,
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required String message,
    String? title,
    String? buttonText,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ErrorModal(
        message: message,
        title: title,
        buttonText: buttonText ?? 'OK',
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title ?? 'Error',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.5,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Bottom - Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClose?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,

                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for easy usage
// Example: context.showErrorModal('Error message');
extension ErrorModalExtension on BuildContext {
  void showErrorModal({
    required String message,
    String? title,
    String? buttonText,
    VoidCallback? onClose,
  }) {
    ErrorModal.show(
      context: this,
      message: message,
      title: title,
      buttonText: buttonText,
      onClose: onClose,
    );
  }
}
