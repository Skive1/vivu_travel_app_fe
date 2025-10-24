import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_container.dart';

class AuthScreenLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final bool showBackButton;

  const AuthScreenLayout({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: AuthContainer(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: keyboardHeight + 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Top Section
                  Column(
                    children: [
                      // Back Button
                      if (showBackButton)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFF1A1A1A),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      
                      if (showBackButton) SizedBox(height: screenSize.height * 0.02),
                      
                      // Vivu Travel Logo
                      Container(
                        width: 240.0,
                        height: 240.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(120.0),
                          child: Image.asset(
                            'assets/images/vivu_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: screenSize.height * 0.02),
                      
                      // Header
                      Column(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Content Section
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
