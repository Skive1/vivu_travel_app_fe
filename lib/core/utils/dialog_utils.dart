import 'package:flutter/material.dart';
import '../widgets/error_dialog.dart';
import '../widgets/success_dialog.dart';

class DialogUtils {
  static Future<void> showErrorDialog({
    required BuildContext context,
    String? title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title ?? 'Error',
          message: message,
          buttonText: buttonText,
          onPressed: onPressed,
        );
      },
    );
  }

  static Future<void> showSuccessDialog({
    required BuildContext context,
    String? title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(
          title: title ?? 'Success',
          message: message,
          buttonText: buttonText,
          onPressed: onPressed,
        );
      },
    );
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    String? title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title ?? 'Confirm',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(confirmText ?? 'Confirm'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showLoadingDialog({
    required BuildContext context,
    String? message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
