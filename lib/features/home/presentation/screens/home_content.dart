import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../widgets/home_header.dart';
import '../widgets/home_body.dart';

class HomeContentWidget extends StatefulWidget {
  const HomeContentWidget({super.key});

  @override
  State<HomeContentWidget> createState() => _HomeContentWidgetState();
}

class _HomeContentWidgetState extends State<HomeContentWidget> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: context.responsive(
              verySmall: 15,
              small: 18,
              large: 20,
            ),
            offset: context.responsive(
              verySmall: const Offset(0, 8),
              small: const Offset(0, 9),
              large: const Offset(0, 10),
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
          verySmall: 20,
          small: 25,
          large: 30,
        )),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: HomeBody(
                  onRefresh: () async => Future<void>.delayed(const Duration(seconds: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
