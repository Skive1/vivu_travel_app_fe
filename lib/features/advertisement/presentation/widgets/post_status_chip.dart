import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/post_entity.dart';

class PostStatusChip extends StatelessWidget {
  final PostStatus status;

  const PostStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.responsivePadding(
        horizontal: context.responsive(
          verySmall: 6.0,
          small: 8.0,
          large: 10.0,
        ),
        vertical: context.responsive(
          verySmall: 2.0,
          small: 3.0,
          large: 4.0,
        ),
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 8.0,
            small: 10.0,
            large: 12.0,
          ),
        ),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: context.responsiveFontSize(
            verySmall: 10.0,
            small: 11.0,
            large: 12.0,
          ),
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case PostStatus.pending:
        return Colors.orange;
      case PostStatus.approved:
        return Colors.green;
      case PostStatus.rejected:
        return Colors.red;
    }
  }
}
