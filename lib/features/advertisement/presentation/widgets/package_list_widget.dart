import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/package_entity.dart';
import 'package_card_widget.dart';
import 'purchased_package_card_widget.dart';
import 'empty_state_widget.dart';
import '../screens/payment_screen.dart';
import '../bloc/advertisement_bloc.dart';

class PackageListWidget extends StatelessWidget {
  final List<PackageEntity> packages;
  final bool isLoading;
  final bool hasLoaded;
  final bool showPurchaseButton;
  final VoidCallback? onPurchaseSuccess;

  const PackageListWidget({
    super.key,
    required this.packages,
    this.isLoading = false,
    this.hasLoaded = false,
    this.showPurchaseButton = true,
    this.onPurchaseSuccess,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading indicator when loading and no data yet
    if (isLoading && !hasLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    // Show empty state only when data has been loaded and is actually empty
    if (hasLoaded && packages.isEmpty) {
      return EmptyStateWidget(
        icon: showPurchaseButton ? Icons.card_giftcard_outlined : Icons.history_outlined,
        title: showPurchaseButton ? 'Chưa có gói dịch vụ nào' : 'Chưa có gói đã mua',
        subtitle: showPurchaseButton 
            ? 'Các gói dịch vụ quảng cáo sẽ hiển thị tại đây'
            : 'Lịch sử mua gói dịch vụ sẽ hiển thị tại đây',
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
          child: showPurchaseButton 
              ? PackageCardWidget(
                  package: package,
                  onTap: () => _navigateToPackageDetail(context, package),
                  onPurchase: () => _showPurchaseDialog(context, package),
                )
              : PurchasedPackageCardWidget(
                  package: package,
                  onTap: () => _navigateToPackageDetail(context, package),
                ),
        );
      },
    );
  }

  void _navigateToPackageDetail(BuildContext context, PackageEntity package) {
    if (showPurchaseButton) {
      // For available packages - show purchase info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xem chi tiết gói: ${package.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // For purchased packages - show transaction details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xem chi tiết giao dịch: ${package.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPurchaseDialog(BuildContext context, PackageEntity package) async {
    final bloc = context.read<AdvertisementBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: PaymentScreen(package: package),
        ),
      ),
    );
    // Always force parent to switch to Packages tab and reload
    if (onPurchaseSuccess != null) onPurchaseSuccess!();
  }
}
