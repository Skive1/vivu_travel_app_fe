import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SocialAuthButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool isLoading;
  
  const SocialAuthButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isLoading = false,
  });

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: 8.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      _handleTapEnd();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) {
      _handleTapEnd();
    }
  }

  void _handleTapEnd() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTap() {
    if (!widget.isLoading) {
      HapticFeedback.selectionClick();
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isPressed ? 0.05 : 0.1),
                    blurRadius: _shadowAnimation.value,
                    spreadRadius: _isPressed ? 0.5 : 1,
                    offset: Offset(0, _isPressed ? 1 : 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: widget.isLoading ? null : _handleTap,
                  splashColor: Colors.grey.withValues(alpha: 0.1),
                  highlightColor: Colors.grey.withValues(alpha: 0.05),
                  child: Center(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: widget.isLoading
                          ? CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[400]!,
                              ),
                            )
                          : widget.icon,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}