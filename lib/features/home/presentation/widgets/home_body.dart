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
            
            // Search Section
            const SearchSection(),
            
            const SizedBox(height: 32),
            
            // Popular Destinations Section
            const PopularDestinationsSection(),
            
            const SizedBox(height: 32),
            
            // Recent Trips Section
            const RecentTripsSection(),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }
}