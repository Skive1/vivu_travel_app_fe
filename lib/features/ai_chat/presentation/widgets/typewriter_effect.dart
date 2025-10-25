import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TypewriterEffect extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final VoidCallback? onComplete;

  const TypewriterEffect({
    Key? key,
    required this.text,
    this.duration = const Duration(milliseconds: 50),
    this.style,
    this.onComplete,
  }) : super(key: key);

  @override
  State<TypewriterEffect> createState() => _TypewriterEffectState();
}

class _TypewriterEffectState extends State<TypewriterEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * widget.duration.inMilliseconds),
      vsync: this,
    );

    _animation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animation.addListener(() {
      setState(() {
        _displayText = widget.text.substring(0, _animation.value);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _displayText,
            style: widget.style,
          ),
          if (_displayText.length < widget.text.length)
            TextSpan(
              text: '|',
              style: (widget.style ?? const TextStyle()).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
