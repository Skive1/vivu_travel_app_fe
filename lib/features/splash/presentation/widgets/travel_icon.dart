import 'package:flutter/material.dart';
import 'package:vivu_travel/features/splash/presentation/widgets/travel_logo_painter.dart';

class TravelIcon extends StatelessWidget {
  const TravelIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: FigmaTravelLogoPainter(),
      ),
    );
  }
}