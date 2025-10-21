import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';

class RichTextRenderer extends StatelessWidget {
  final String content;
  final List<String> mediaUrls;
  final List<int> mediaTypes; // 0 for image, 1 for video

  const RichTextRenderer({
    super.key,
    required this.content,
    required this.mediaUrls,
    required this.mediaTypes,
  });

  @override
  Widget build(BuildContext context) {
    return _parseContent(context);
  }

  Widget _parseContent(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Skip empty lines
      if (line.trim().isEmpty) {
        widgets.add(SizedBox(height: context.responsive(verySmall: 8.0, small: 10.0, large: 12.0)));
        continue;
      }

      // Check if line contains image placeholder
      if (line.contains('[IMAGE:') && line.contains(']')) {
        widgets.add(_parseLineWithImages(context, line));
      } else {
        // Parse line for formatting
        widgets.add(_parseLine(context, line));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _parseLineWithImages(BuildContext context, String line) {
    final parts = <Widget>[];
    final regex = RegExp(r'\[IMAGE:(\d+)\]');
    int lastIndex = 0;
    
    for (final match in regex.allMatches(line)) {
      // Add text before image
      if (match.start > lastIndex) {
        final textBefore = line.substring(lastIndex, match.start);
        if (textBefore.trim().isNotEmpty) {
          parts.add(_parseInlineFormatting(context, textBefore));
        }
      }
      
      // Add image
      final imageIndex = int.tryParse(match.group(1)!);
      if (imageIndex != null && imageIndex < mediaUrls.length) {
        parts.add(_buildInlineImage(context, imageIndex));
      }
      
      lastIndex = match.end;
    }
    
    // Add remaining text after last image
    if (lastIndex < line.length) {
      final textAfter = line.substring(lastIndex);
      if (textAfter.trim().isNotEmpty) {
        parts.add(_parseInlineFormatting(context, textAfter));
      }
    }
    
    // If no text parts, just return the images
    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // If only one part, return it directly
    if (parts.length == 1) {
      return parts.first;
    }
    
    // Multiple parts - wrap in Row
    return Wrap(
      children: parts,
    );
  }


  Widget _parseLine(BuildContext context, String line) {
    // Handle indentation
    final indentLevel = _getIndentLevel(line);
    final content = line.trim();

    // Handle list items
    if (content.startsWith('• ') || content.startsWith('- ')) {
      return _buildListItem(context, content.substring(2), indentLevel, false);
    }
    
    if (RegExp(r'^\d+\. ').hasMatch(content)) {
      final match = RegExp(r'^(\d+)\. (.+)$').firstMatch(content);
      if (match != null) {
        return _buildListItem(context, match.group(2)!, indentLevel, true, int.parse(match.group(1)!));
      }
    }

    // Handle regular text with formatting
    return _buildFormattedText(context, content, indentLevel);
  }

  int _getIndentLevel(String line) {
    int level = 0;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == ' ') {
        level++;
      } else {
        break;
      }
    }
    return (level / 4).floor(); // Assuming 4 spaces per indent level
  }

  Widget _buildListItem(BuildContext context, String text, int indentLevel, bool isNumbered, [int? number]) {
    return Padding(
      padding: EdgeInsets.only(
        left: indentLevel * context.responsive(verySmall: 16.0, small: 20.0, large: 24.0),
        bottom: context.responsive(verySmall: 4.0, small: 6.0, large: 8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNumbered)
            Text(
              '${number}. ',
              style: TextStyle(
                fontSize: context.responsiveFontSize(verySmall: 15.0, small: 16.0, large: 17.0),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              '• ',
              style: TextStyle(
                fontSize: context.responsiveFontSize(verySmall: 15.0, small: 16.0, large: 17.0),
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          Expanded(
            child: _buildFormattedText(context, text, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(BuildContext context, String text, int indentLevel) {
    return Padding(
      padding: EdgeInsets.only(
        left: indentLevel * context.responsive(verySmall: 16.0, small: 20.0, large: 24.0),
        bottom: context.responsive(verySmall: 8.0, small: 10.0, large: 12.0),
      ),
      child: _parseInlineFormatting(context, text),
    );
  }

  Widget _parseInlineFormatting(BuildContext context, String text) {
    final spans = <TextSpan>[];
    final buffer = StringBuffer();
    bool inBold = false;
    bool inItalic = false;
    bool inUnderline = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      
      if (char == '*' && i + 1 < text.length && text[i + 1] == '*') {
        // Bold formatting
        if (buffer.isNotEmpty) {
          spans.add(_createTextSpan(context, buffer.toString(), inBold, inItalic, inUnderline));
          buffer.clear();
        }
        inBold = !inBold;
        i++; // Skip next *
      } else if (char == '_' && i + 1 < text.length && text[i + 1] == '_') {
        // Italic formatting
        if (buffer.isNotEmpty) {
          spans.add(_createTextSpan(context, buffer.toString(), inBold, inItalic, inUnderline));
          buffer.clear();
        }
        inItalic = !inItalic;
        i++; // Skip next _
      } else if (char == '~' && i + 1 < text.length && text[i + 1] == '~') {
        // Underline formatting
        if (buffer.isNotEmpty) {
          spans.add(_createTextSpan(context, buffer.toString(), inBold, inItalic, inUnderline));
          buffer.clear();
        }
        inUnderline = !inUnderline;
        i++; // Skip next ~
      } else {
        buffer.write(char);
      }
    }

    // Add remaining text
    if (buffer.isNotEmpty) {
      spans.add(_createTextSpan(context, buffer.toString(), inBold, inItalic, inUnderline));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  TextSpan _createTextSpan(BuildContext context, String text, bool bold, bool italic, bool underline) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontSize: context.responsiveFontSize(verySmall: 15.0, small: 16.0, large: 17.0),
        color: AppColors.textPrimary,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
        height: 1.6,
      ),
    );
  }

  Widget _buildInlineImage(BuildContext context, int index) {
    final imageUrl = mediaUrls[index];
    final isVideo = index < mediaTypes.length && mediaTypes[index] == 1;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsive(verySmall: 4.0, small: 6.0, large: 8.0),
        vertical: context.responsive(verySmall: 2.0, small: 4.0, large: 6.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: context.responsive(verySmall: 80.0, small: 100.0, large: 120.0),
              height: context.responsive(verySmall: 80.0, small: 100.0, large: 120.0),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: context.responsive(verySmall: 80.0, small: 100.0, large: 120.0),
                  height: context.responsive(verySmall: 80.0, small: 100.0, large: 120.0),
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                  ),
                );
              },
            ),
            if (isVideo)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: context.responsiveIconSize(verySmall: 24.0, small: 28.0, large: 32.0),
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
