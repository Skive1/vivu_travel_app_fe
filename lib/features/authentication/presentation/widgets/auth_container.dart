import 'package:flutter/material.dart';

class AuthContainer extends StatelessWidget {
  final Widget child;
  
  const AuthContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}