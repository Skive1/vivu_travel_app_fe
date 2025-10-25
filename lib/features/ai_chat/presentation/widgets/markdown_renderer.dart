import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/constants/app_colors.dart';

class MarkdownRenderer extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MarkdownRenderer({Key? key, required this.text, this.style})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter out JSON parts from aiMessage
    final filteredText = _filterJsonContent(text);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textHint.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: MarkdownBody(
        data: filteredText,
        styleSheet: MarkdownStyleSheet(
          // H1 styling (only level 1 headers)
          h1: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.3,
          ),
          // Hide other header levels
          h2: const TextStyle(fontSize: 0, height: 0),
          h3: const TextStyle(fontSize: 0, height: 0),
          h4: const TextStyle(fontSize: 0, height: 0),
          h5: const TextStyle(fontSize: 0, height: 0),
          h6: const TextStyle(fontSize: 0, height: 0),
          // Paragraph styling
          p: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            height: 1.5,
            letterSpacing: 0.2,
          ),
          // List styling
          listBullet: TextStyle(color: AppColors.primary, fontSize: 16),
          // Strong/Bold styling
          strong: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          // Emphasis/Italic styling
          em: TextStyle(
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
          // Code styling
          code: TextStyle(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            color: AppColors.primary,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          // Blockquote styling
          blockquote: TextStyle(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
            fontSize: 15,
          ),
          // Link styling
          a: TextStyle(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
        ),
        selectable: true,
        onTapLink: (text, href, title) {
          // Handle link taps if needed
        },
      ),
    );
  }

  /// Filter out JSON content from aiMessage
  /// Only show natural text content before JSON parts
  String _filterJsonContent(String text) {
    if (text.isEmpty) return text;

    // 1) Chuẩn hóa xuống dòng
    String s = text.replaceAll('\r\n', '\n');

    // 2) Tìm vị trí "ngăn cách ---" NGAY TRƯỚC heading "### ... Phần JSON"
    //    Mẫu: (optional newlines) --- (optional newlines) ### ... Phần JSON
    final sepBeforeJson = RegExp(
      r'\n\s*---\s*\n\s*###\s*[\d️⃣\.\s]*Phần\s+JSON',
      caseSensitive: false,
    ).firstMatch(s);

    if (sepBeforeJson != null) {
      // Cắt trước dòng '---' (match.start trỏ về đầu khối ngăn cách)
      final cut = s.substring(0, sepBeforeJson.start);

      // Dọn khoảng trắng/dấu gạch cuối nếu có dư
      return cut.replaceAll(RegExp(r'\s+$'), '').trimRight();
    }

    // 3) Fallback: nếu không có heading "Phần JSON", cắt trước code fence ```json đầu tiên
    final fenceJson = RegExp(r'```json').firstMatch(s);
    if (fenceJson != null) {
      // Cố gắng lùi về một '---' liền trước nếu có
      final beforeFence = s.substring(0, fenceJson.start);
      final lastSep = beforeFence.lastIndexOf('\n---');
      if (lastSep != -1) {
        return s
            .substring(0, lastSep)
            .replaceAll(RegExp(r'\s+$'), '')
            .trimRight();
      }
      // Nếu không tìm được '---' thì cắt ngay trước ```json
      return beforeFence.replaceAll(RegExp(r'\s+$'), '').trimRight();
    }

    // 4) Không có JSON/heading nào -> trả nguyên
    return s;
  }
}
