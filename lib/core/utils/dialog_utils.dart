import 'package:flutter/material.dart';
import '../widgets/error_dialog.dart';
import '../widgets/success_dialog.dart';

class DialogUtils {
  static bool _isErrorDialogShowing = false;
  static Future<void> showErrorDialog({
    required BuildContext context,
    String? title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool useRootNavigator = true,
  }) {
    if (_isErrorDialogShowing) {
      return Future.value();
    }
    _isErrorDialogShowing = true;
    return showDialog<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title ?? 'Error',
          message: message,
          buttonText: buttonText,
          onPressed: onPressed,
        );
      },
    ).whenComplete(() {
      _isErrorDialogShowing = false;
    });
  }

  static Future<void> showSuccessDialog({
    required BuildContext context,
    String? title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool useRootNavigator = true,
  }) {
    return showDialog<void>(
      context: context,
      useRootNavigator: useRootNavigator,
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

  static Future<void> showCustomDialog({
    required BuildContext context,
    required Widget dialog,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => dialog,
    );
  }

  /// Parse and format error messages from server responses
  static String _parseErrorMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Handle specific business logic errors
    if (lowerMessage.contains('just check-in') || lowerMessage.contains('already check-in')) {
      return 'Bạn đã check-in vào hoạt động này rồi.\n\n💡 Mỗi hoạt động chỉ có thể check-in một lần.';
    } else if (lowerMessage.contains('not check-in') || lowerMessage.contains('need check-in')) {
      return 'Bạn cần check-in trước khi check-out.\n\n💡 Vui lòng check-in trước khi thực hiện check-out.';
    } else if (lowerMessage.contains('already check-out') || lowerMessage.contains('just check-out')) {
      return 'Bạn đã check-out khỏi hoạt động này rồi.\n\n💡 Mỗi hoạt động chỉ có thể check-out một lần.';
    } else if (lowerMessage.contains('activity not found') || lowerMessage.contains('not exist')) {
      return 'Không tìm thấy hoạt động.\n\n💡 Hoạt động có thể đã bị xóa hoặc không tồn tại.';
    } else if (lowerMessage.contains('permission denied') || lowerMessage.contains('not allowed')) {
      return 'Bạn không có quyền thực hiện hành động này.\n\n💡 Liên hệ quản trị viên để được cấp quyền.';
    }
    
    // Handle technical errors
    if (lowerMessage.contains('network') || lowerMessage.contains('connection')) {
      return '$message\n\n💡 Kiểm tra kết nối internet và thử lại.';
    } else if (lowerMessage.contains('timeout')) {
      return '$message\n\n💡 Kết nối chậm, vui lòng thử lại sau.';
    } else if (lowerMessage.contains('unauthorized') || lowerMessage.contains('token')) {
      return '$message\n\n💡 Vui lòng đăng nhập lại.';
    } else if (lowerMessage.contains('server') || lowerMessage.contains('internal')) {
      return '$message\n\n💡 Lỗi từ server, vui lòng thử lại sau.';
    }
    
    // Return original message if no specific handling
    return message;
  }

  /// Show error dialog with smart error parsing
  static Future<void> showServerErrorDialog({
    required BuildContext context,
    required String serverMessage,
    String? title,
    String? buttonText,
    VoidCallback? onPressed,
    bool useRootNavigator = true,
  }) {
    return showErrorDialog(
      context: context,
      title: title ?? 'Lỗi',
      message: serverMessage,
      buttonText: buttonText,
      onPressed: onPressed,
      useRootNavigator: useRootNavigator,
    );
  }
}
