import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/package_entity.dart';
import 'package_card_widget.dart';
import 'empty_state_widget.dart';
import '../screens/payment_screen.dart';

class PackageListWidget extends StatelessWidget {
  final List<PackageEntity> packages;
  final bool isLoading;

  const PackageListWidget({
    super.key,
    required this.packages,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && packages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (packages.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.card_giftcard_outlined,
        title: 'Chưa có gói dịch vụ nào',
        subtitle: 'Các gói dịch vụ quảng cáo sẽ hiển thị tại đây',
        actionText: 'Làm mới',
        onAction: () {
          // Refresh will be handled by parent
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        right: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        top: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        bottom: context.responsive(
          verySmall: 80.0,
          small: 90.0,
          large: 100.0,
        ),
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: context.responsiveSpacing(
              verySmall: 12.0,
              small: 16.0,
              large: 20.0,
            ),
          ),
          child: PackageCardWidget(
            package: package,
            onTap: () => _navigateToPackageDetail(context, package),
            onPurchase: () => _showPurchaseDialog(context, package),
          ),
        );
      },
    );
  }

  void _navigateToPackageDetail(BuildContext context, PackageEntity package) {
    // TODO: Navigate to package detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xem chi tiết gói: ${package.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, PackageEntity package) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(package: package),
      ),
    );
  }
}
