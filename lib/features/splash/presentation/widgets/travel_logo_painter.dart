import 'package:flutter/material.dart';

class FigmaTravelLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Scale to match the 190x200 viewBox of SVG
    final scaleX = size.width / 190;
    final scaleY = size.height / 200;

    path.moveTo(16.7416 * scaleX, 52.2167 * scaleY);
    path.cubicTo(18.2666 * scaleX, 50.1667 * scaleY, 20.275 * scaleX, 47.3917 * scaleY, 21.8833 * scaleX, 45.4083 * scaleY);
    path.cubicTo(26.7 * scaleX, 39.9417 * scaleY, 27.325 * scaleX, 39.225 * scaleY, 31.7083 * scaleX, 35.1833 * scaleY);
    path.cubicTo(33.0083 * scaleX, 34.1167 * scaleY, 34.55 * scaleX, 32.8333 * scaleY, 36.0583 * scaleX, 31.625 * scaleY);
    path.cubicTo(24.9333 * scaleX, 41.0417 * scaleY, 23.5166 * scaleX, 51.4667 * scaleY, 33.725 * scaleX, 57.9083 * scaleY);
    path.cubicTo(33.7083 * scaleX, 57.9083 * scaleY, 33.7083 * scaleX, 57.9083 * scaleY, 33.7083 * scaleX, 57.925 * scaleY);
    path.cubicTo(47.9833 * scaleX, 66.525 * scaleY, 79.2666 * scaleX, 64.6667 * scaleY, 103.95 * scaleX, 53.65 * scaleY);
    path.cubicTo(127.858 * scaleX, 42.9833 * scaleY, 136.683 * scaleX, 27.725 * scaleY, 124.883 * scaleX, 18.6583 * scaleY);
    path.cubicTo(114.525 * scaleX, 16.7167 * scaleY, 102.175 * scaleX, 16.4917 * scaleY, 89.1083 * scaleX, 18.2417 * scaleY);
    path.lineTo(87.75 * scaleX, 16 * scaleY);
    path.lineTo(88.875 * scaleX, 12.2833 * scaleY);
    path.cubicTo(96.5583 * scaleX, 11.5917 * scaleY, 103.858 * scaleX, 11.7583 * scaleY, 110.158 * scaleX, 12.8333 * scaleY);
    path.cubicTo(111.683 * scaleX, 13.0917 * scaleY, 113.692 * scaleX, 13.5333 * scaleY, 115.192 * scaleX, 13.85 * scaleY);
    path.cubicTo(118.092 * scaleX, 14.5583 * scaleY, 119.667 * scaleX, 14.9833 * scaleY, 121.558 * scaleX, 15.5917 * scaleY);
    path.cubicTo(123.492 * scaleX, 16.1667 * scaleY, 125.142 * scaleX, 16.7417 * scaleY, 128.017 * scaleX, 17.8083 * scaleY);
    path.cubicTo(130.833 * scaleX, 18.9167 * scaleY, 132.05 * scaleX, 19.4167 * scaleY, 134.308 * scaleX, 20.5417 * scaleY);
    path.cubicTo(136.837 * scaleX, 21.6955 * scaleY, 139.295 * scaleX, 23.0007 * scaleY, 141.667 * scaleX, 24.45 * scaleY);
    path.cubicTo(160.467 * scaleX, 36.275 * scaleY, 148.775 * scaleX, 57.85 * scaleY, 115.6 * scaleX, 72.6333 * scaleY);
    path.cubicTo(82.5166 * scaleX, 87.3667 * scaleY, 40.3583 * scaleX, 89.6833 * scaleY, 21.4666 * scaleX, 78 * scaleY);
    path.cubicTo(21.4583 * scaleX, 77.9833 * scaleY, 21.4333 * scaleX, 77.9667 * scaleY, 21.3833 * scaleX, 77.95 * scaleY);
    path.lineTo(21.4166 * scaleX, 77.95 * scaleY);
    path.cubicTo(11.1 * scaleX, 71.4167 * scaleY, 10.0166 * scaleX, 61.9333 * scaleY, 16.7416 * scaleX, 52.2167 * scaleY);
    path.close();

    path.moveTo(102.817 * scaleX, 134.883 * scaleY);
    path.lineTo(102.55 * scaleX, 121.6 * scaleY);
    path.lineTo(93.1083 * scaleX, 111.1 * scaleY);
    path.cubicTo(61.9166 * scaleX, 118.167 * scaleY, 31.2583 * scaleX, 116.65 * scaleY, 14.2083 * scaleX, 106.608 * scaleY);
    path.cubicTo(14.15 * scaleX, 106.542 * scaleY, 14.0083 * scaleX, 106.475 * scaleY, 13.95 * scaleX, 106.408 * scaleY);
    path.cubicTo(4.29997 * scaleX, 100.467 * scaleY, 1.91663 * scaleX, 92.8 * scaleY, 2.64163 * scaleX, 84.4667 * scaleY);
    path.cubicTo(0.383299 * scaleX, 96.6583 * scaleY, 0.199966 * scaleX, 101.058 * scaleY, 0.524966 * scaleX, 111.492 * scaleY);
    path.cubicTo(0.924966 * scaleX, 118.025 * scaleY, 4.69997 * scaleX, 124.05 * scaleY, 12.2916 * scaleX, 128.8 * scaleY);
    path.lineTo(12.35 * scaleX, 128.867 * scaleY);
    path.cubicTo(30.525 * scaleX, 140.167 * scaleY, 68.3916 * scaleX, 142.617 * scaleY, 102.817 * scaleX, 134.883 * scaleY);
    path.close();

    path.moveTo(142.192 * scaleX, 150.092 * scaleY);
    path.cubicTo(98.1666 * scaleX, 167.75 * scaleY, 43.0666 * scaleX, 168.792 * scaleY, 19.1333 * scaleX, 152.45 * scaleY);
    path.cubicTo(21.7179 * scaleX, 158.766 * scaleY, 25.2348 * scaleX, 164.66 * scaleY, 29.5666 * scaleX, 169.933 * scaleY);
    path.cubicTo(51.5333 * scaleX, 184.933 * scaleY, 102.108 * scaleX, 183.975 * scaleY, 142.5 * scaleX, 167.767 * scaleY);
    path.cubicTo(166.142 * scaleX, 158.292 * scaleY, 181.058 * scaleX, 145.683 * scaleY, 184.975 * scaleX, 133.867 * scaleY);
    path.lineTo(186.075 * scaleX, 130.308 * scaleY);
    path.cubicTo(188.683 * scaleX, 121.292 * scaleY, 189.175 * scaleX, 113.783 * scaleY, 189.592 * scaleX, 107.1 * scaleY);
    path.cubicTo(189.117 * scaleX, 121.608 * scaleY, 172.025 * scaleX, 138.108 * scaleY, 142.192 * scaleX, 150.092 * scaleY);
    path.close();

    path.moveTo(45.0083 * scaleX, 184.1 * scaleY);
    path.cubicTo(46.3916 * scaleX, 185.417 * scaleY, 50.7416 * scaleX, 190.758 * scaleY, 72.7833 * scaleX, 196.658 * scaleY);
    path.cubicTo(78.7416 * scaleX, 197.975 * scaleY, 93.7416 * scaleX, 202.2 * scaleY, 121.45 * scaleX, 196.058 * scaleY);
    path.lineTo(121.617 * scaleX, 193.533 * scaleY);
    path.lineTo(119.425 * scaleX, 190.1 * scaleY);
    path.cubicTo(93.7166 * scaleX, 196.183 * scaleY, 65.1583 * scaleX, 194.15 * scaleY, 45.0083 * scaleX, 184.1 * scaleY);
    path.close();

    path.moveTo(108.625 * scaleX, 79.025 * scaleY);
    path.lineTo(132.033 * scaleX, 96.7667 * scaleY);
    path.cubicTo(132.033 * scaleX, 96.7667 * scaleY, 137.042 * scaleX, 100.375 * scaleY, 132.317 * scaleX, 102.908 * scaleY);
    path.cubicTo(127.608 * scaleX, 105.417 * scaleY, 115.517 * scaleX, 111.558 * scaleY, 115.517 * scaleX, 111.558 * scaleY);
    path.lineTo(103.575 * scaleX, 107.1 * scaleY);
    path.lineTo(97.5833 * scaleX, 109.767 * scaleY);
    path.lineTo(108.15 * scaleX, 118.942 * scaleY);
    path.lineTo(108.233 * scaleX, 133.217 * scaleY);
    path.lineTo(114.442 * scaleX, 130.458 * scaleY);
    path.lineTo(118.558 * scaleX, 118.4 * scaleY);
    path.cubicTo(118.558 * scaleX, 118.4 * scaleY, 131.2 * scaleX, 113.533 * scaleY, 136.217 * scaleX, 111.7 * scaleY);
    path.cubicTo(141.258 * scaleX, 109.908 * scaleY, 140.583 * scaleX, 116.042 * scaleY, 140.583 * scaleX, 116.042 * scaleY);
    path.lineTo(138.1 * scaleX, 145.3 * scaleY);
    path.lineTo(146.35 * scaleX, 141.633 * scaleY);
    path.lineTo(159.933 * scaleX, 102.158 * scaleY);
    path.cubicTo(159.933 * scaleX, 102.158 * scaleY, 167.133 * scaleX, 98.6583 * scaleY, 172.2 * scaleX, 95.5833 * scaleY);
    path.cubicTo(177.258 * scaleX, 92.5083 * scaleY, 178.992 * scaleX, 87.4083 * scaleY, 178.992 * scaleX, 87.4083 * scaleY);
    path.cubicTo(178.992 * scaleX, 87.4083 * scaleY, 174.058 * scaleX, 85.2833 * scaleY, 168.375 * scaleX, 86.9917 * scaleY);
    path.cubicTo(162.692 * scaleX, 88.6833 * scaleY, 155.283 * scaleX, 91.7 * scaleY, 155.283 * scaleX, 91.7 * scaleY);
    path.lineTo(116.85 * scaleX, 75.375 * scaleY);
    path.lineTo(108.625 * scaleX, 79.025 * scaleY);
    path.close();

    path.moveTo(59.1 * scaleX, 22.8917 * scaleY);
    path.lineTo(74.9916 * scaleX, 35.55 * scaleY);
    path.lineTo(79.3333 * scaleX, 34.9 * scaleY);
    path.lineTo(70.6833 * scaleX, 23.5417 * scaleY);
    path.cubicTo(70.6833 * scaleX, 23.5417 * scaleY, 68.8 * scaleX, 21.1917 * scaleY, 71.3333 * scaleX, 20.6333 * scaleY);
    path.cubicTo(73.8833 * scaleX, 20.0667 * scaleY, 80.3333 * scaleX, 18.75 * scaleY, 80.3333 * scaleX, 18.75 * scaleY);
    path.lineTo(85.1833 * scaleX, 22.625 * scaleY);
    path.lineTo(88.45 * scaleX, 22.1417 * scaleY);
    path.lineTo(84.75 * scaleX, 16.2583 * scaleY);
    path.lineTo(86.7 * scaleX, 9.73333 * scaleY);
    path.lineTo(83.5416 * scaleX, 10.1917 * scaleY);
    path.lineTo(79.8 * scaleX, 15.1583 * scaleY);
    path.cubicTo(79.8 * scaleX, 15.1583 * scaleY, 73.2333 * scaleX, 15.775 * scaleY, 70.65 * scaleX, 15.9917 * scaleY);
    path.cubicTo(68.05 * scaleX, 16.1917 * scaleY, 69.1666 * scaleX, 13.4 * scaleY, 69.1666 * scaleX, 13.4 * scaleY);
    path.lineTo(74.15 * scaleX, 0 * scaleY);
    path.lineTo(69.7833 * scaleX, 0.641667 * scaleY);
    path.lineTo(58.2833 * scaleX, 17.3833 * scaleY);
    path.cubicTo(58.2833 * scaleX, 17.3833 * scaleY, 54.45 * scaleX, 18.0833 * scaleY, 51.675 * scaleX, 18.875 * scaleY);
    path.cubicTo(48.8916 * scaleX, 19.6583 * scaleY, 47.425 * scaleX, 21.8083 * scaleY, 47.425 * scaleX, 21.8083 * scaleY);
    path.cubicTo(47.425 * scaleX, 21.8083 * scaleY, 49.4666 * scaleX, 23.4583 * scaleY, 52.3416 * scaleX, 23.4 * scaleY);
    path.cubicTo(55.2416 * scaleX, 23.3417 * scaleY, 59.1 * scaleX, 22.8917 * scaleY, 59.1 * scaleX, 22.8917 * scaleY);
    path.close();

    path.moveTo(137.642 * scaleX, 185.542 * scaleY);
    path.lineTo(127.358 * scaleX, 180.167 * scaleY);
    path.lineTo(124.992 * scaleX, 180.992 * scaleY);
    path.lineTo(131.083 * scaleX, 186.442 * scaleY);
    path.cubicTo(131.083 * scaleX, 186.442 * scaleY, 132.383 * scaleX, 187.55 * scaleY, 131.017 * scaleX, 188.142 * scaleY);
    path.cubicTo(129.65 * scaleX, 188.725 * scaleY, 126.167 * scaleX, 190.158 * scaleY, 126.167 * scaleX, 190.158 * scaleY);
    path.lineTo(123.292 * scaleX, 188.875 * scaleY);
    path.lineTo(121.583 * scaleX, 189.492 * scaleY);
    path.lineTo(123.975 * scaleX, 192.042 * scaleY);
    path.lineTo(123.742 * scaleX, 195.767 * scaleY);
    path.lineTo(125.525 * scaleX, 195.15 * scaleY);
    path.lineTo(126.858 * scaleX, 192.125 * scaleY);
    path.cubicTo(126.858 * scaleX, 192.125 * scaleY, 130.475 * scaleX, 191.05 * scaleY, 131.917 * scaleX, 190.667 * scaleY);
    path.cubicTo(133.35 * scaleX, 190.275 * scaleY, 133.025 * scaleX, 191.958 * scaleY, 133.025 * scaleX, 191.958 * scaleY);
    path.lineTo(131.667 * scaleX, 200 * scaleY);
    path.lineTo(134.042 * scaleX, 199.175 * scaleY);
    path.lineTo(138.7 * scaleX, 188.542 * scaleY);
    path.cubicTo(138.7 * scaleX, 188.542 * scaleY, 140.758 * scaleX, 187.733 * scaleY, 142.233 * scaleX, 186.992 * scaleY);
    path.cubicTo(143.708 * scaleX, 186.25 * scaleY, 144.292 * scaleX, 184.883 * scaleY, 144.292 * scaleX, 184.883 * scaleY);
    path.cubicTo(144.292 * scaleX, 184.883 * scaleY, 142.983 * scaleX, 184.167 * scaleY, 141.367 * scaleX, 184.525 * scaleY);
    path.cubicTo(139.742 * scaleX, 184.867 * scaleY, 137.642 * scaleX, 185.542 * scaleY, 137.642 * scaleX, 185.542 * scaleY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}