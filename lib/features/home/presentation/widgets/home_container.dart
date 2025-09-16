import 'package:flutter/material.dart';

import 'home_content.dart';

class HomeContainer extends StatelessWidget {
  const HomeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Center(
      child: Container(
        width: screenSize.width > 375 ? 375 : screenSize.width,
        height: screenSize.height > 812 ? 812 : screenSize.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const HomeContent(),
      ),
    );
  }
}
