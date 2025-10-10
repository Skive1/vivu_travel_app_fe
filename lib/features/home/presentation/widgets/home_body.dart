import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'search_section.dart';
import 'popular_destinations_section.dart';
import 'recent_trips_section.dart';

class HomeBody extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const HomeBody({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const SearchSection(),
            const SizedBox(height: 32),

            const PopularDestinationsSection(),
            const SizedBox(height: 32),

            const RecentTripsSection(),

            SizedBox(height: bottomSafe + 12),
          ],
        ),
      ),
    );
  }
}
