import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/user_storage.dart';
import '../../domain/entities/package_entity.dart';
import '../bloc/advertisement_bloc.dart';
import '../bloc/advertisement_event.dart';
import '../bloc/advertisement_state.dart';

class PackageSelectorWidget extends StatefulWidget {
  final String? selectedPackageId;
  final ValueChanged<String?> onPackageSelected;

  const PackageSelectorWidget({
    super.key,
    this.selectedPackageId,
    required this.onPackageSelected,
  });

  @override
  State<PackageSelectorWidget> createState() => _PackageSelectorWidgetState();
}

class _PackageSelectorWidgetState extends State<PackageSelectorWidget> {
  String? _selectedPackageId;
  List<PackageEntity>? _cachedPackages;

  @override
  void initState() {
    super.initState();
    _selectedPackageId = widget.selectedPackageId;
    // Load purchased packages when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchasedPackages();
    });
  }

  @override
  void didUpdateWidget(PackageSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected package ID if it changed from parent
    if (oldWidget.selectedPackageId != widget.selectedPackageId) {
      setState(() {
        _selectedPackageId = widget.selectedPackageId;
      });
    }
  }

  void _loadPurchasedPackages() async {
    final user = await UserStorage.getUserProfile();
    if (user?.id != null) {
      // Only load if not already loading or loaded
      final currentState = context.read<AdvertisementBloc>().state;
      if (currentState is! PurchasedPackagesLoaded && 
          currentState is! AdvertisementLoading) {
        context.read<AdvertisementBloc>().add(LoadPurchasedPackages(user!.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvertisementBloc, AdvertisementState>(
      builder: (context, state) {
        // Update cache when new data arrives
        if (state is PurchasedPackagesLoaded) {
          _cachedPackages = state.packages;
          // When parent passes selectedPackageId late, keep it synced
          if (_selectedPackageId == null && widget.selectedPackageId != null) {
            _selectedPackageId = widget.selectedPackageId;
          }
          return _buildPackageSelector(state.packages);
        }

        // If loading but we have cache, show cached data (no flicker/empty)
        if (state is AdvertisementLoading && _cachedPackages != null) {
          return _buildPackageSelector(_cachedPackages!);
        }

        // If error but we have cache, still prefer showing cached data
        if (state is AdvertisementError && _cachedPackages != null) {
          return _buildPackageSelector(_cachedPackages!);
        }

        // Fallbacks
        if (state is AdvertisementLoading) {
          return _buildLoadingState();
        }
        if (state is AdvertisementError) {
          return _buildErrorState(state.message);
        }
        if (_cachedPackages != null) {
          return _buildPackageSelector(_cachedPackages!);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(context.responsive(verySmall: 16.0, small: 20.0, large: 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard_outlined,
                  color: AppColors.primary,
                  size: context.responsiveIconSize(verySmall: 18.0, small: 20.0, large: 22.0),
                ),
              ),
              SizedBox(width: context.responsiveSpacing(verySmall: 12.0, small: 14.0, large: 16.0)),
              Text(
                'Chọn gói dịch vụ',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(verySmall: 16.0, small: 18.0, large: 20.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 16.0, small: 20.0, large: 24.0)),
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelector(List<PackageEntity> packages) {
    if (packages.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: EdgeInsets.all(context.responsive(verySmall: 16.0, small: 20.0, large: 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard_outlined,
                  color: AppColors.primary,
                  size: context.responsiveIconSize(verySmall: 18.0, small: 20.0, large: 22.0),
                ),
              ),
              SizedBox(width: context.responsiveSpacing(verySmall: 12.0, small: 14.0, large: 16.0)),
              Text(
                'Chọn gói dịch vụ',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(verySmall: 16.0, small: 18.0, large: 20.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 8.0, small: 10.0, large: 12.0)),
          Text(
            'Chọn gói dịch vụ để sử dụng cho bài đăng này',
            style: TextStyle(
              fontSize: context.responsiveFontSize(verySmall: 12.0, small: 13.0, large: 14.0),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 16.0, small: 20.0, large: 24.0)),
          ...packages.map((package) => _buildPackageOption(package)).toList(),
        ],
      ),
    );
  }

  Widget _buildPackageOption(PackageEntity package) {
    final isSelected = _selectedPackageId == package.id;
    final isActive = package.isActive;

    return GestureDetector(
      onTap: isActive ? () => _selectPackage(package.id) : null,
      child: Container(
        margin: EdgeInsets.only(
          bottom: context.responsiveSpacing(verySmall: 8.0, small: 10.0, large: 12.0),
        ),
        padding: EdgeInsets.all(context.responsive(verySmall: 12.0, small: 14.0, large: 16.0)),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: isActive ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary
                : isActive 
                    ? const Color(0xFFE2E8F0)
                    : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? AppColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primary
                      : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
            SizedBox(width: context.responsiveSpacing(verySmall: 12.0, small: 14.0, large: 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(verySmall: 14.0, small: 15.0, large: 16.0),
                      fontWeight: FontWeight.w600,
                      color: isActive 
                          ? AppColors.textPrimary
                          : Colors.grey,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(verySmall: 4.0, small: 6.0, large: 8.0)),
                  Text(
                    '${package.maxPostCount} bài đăng • ${package.durationInDays} ngày',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(verySmall: 12.0, small: 13.0, large: 14.0),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isActive)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(verySmall: 8.0, small: 10.0, large: 12.0),
                  vertical: context.responsive(verySmall: 4.0, small: 6.0, large: 8.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Hết hạn',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(verySmall: 10.0, small: 11.0, large: 12.0),
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(context.responsive(verySmall: 16.0, small: 20.0, large: 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.card_giftcard_outlined,
              color: AppColors.primary,
              size: context.responsiveIconSize(verySmall: 32.0, small: 36.0, large: 40.0),
            ),
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 16.0, small: 20.0, large: 24.0)),
          Text(
            'Chưa có gói dịch vụ',
            style: TextStyle(
              fontSize: context.responsiveFontSize(verySmall: 16.0, small: 18.0, large: 20.0),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 8.0, small: 10.0, large: 12.0)),
            Text(
              'Bạn cần mua gói dịch vụ để có thể đăng bài',
              style: TextStyle(
                fontSize: context.responsiveFontSize(verySmall: 12.0, small: 13.0, large: 14.0),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: EdgeInsets.all(context.responsive(verySmall: 16.0, small: 20.0, large: 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: context.responsiveIconSize(verySmall: 32.0, small: 36.0, large: 40.0),
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 16.0, small: 20.0, large: 24.0)),
          Text(
            'Lỗi tải gói dịch vụ',
            style: TextStyle(
              fontSize: context.responsiveFontSize(verySmall: 16.0, small: 18.0, large: 20.0),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 8.0, small: 10.0, large: 12.0)),
            Text(
              message,
              style: TextStyle(
                fontSize: context.responsiveFontSize(verySmall: 12.0, small: 13.0, large: 14.0),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  void _selectPackage(String packageId) {
    setState(() {
      _selectedPackageId = packageId;
    });
    widget.onPackageSelected(packageId);
  }
}
