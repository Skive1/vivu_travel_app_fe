import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive_utils.dart';
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: AuthContainer(
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: context.responsivePadding(
                    horizontal: context.responsive(
                      verySmall: 16.0,
                      small: 20.0,
                      large: 24.0,
                    ),
                    vertical: context.responsiveSpacing(
                      verySmall: 20.0,
                      small: 32.0,
                      large: 40.0,
                    ),
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
                                  width: context.responsive(
                                    verySmall: 36.0,
                                    small: 40.0,
                                    large: 44.0,
                                  ),
                                  height: context.responsive(
                                    verySmall: 36.0,
                                    small: 40.0,
                                    large: 44.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                                      verySmall: 8.0,
                                      small: 10.0,
                                      large: 12.0,
                                    )),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: const Color(0xFF1A1A1A),
                                    size: context.responsiveIconSize(
                                      verySmall: 16.0,
                                      small: 18.0,
                                      large: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          if (showBackButton) SizedBox(height: context.responsiveSpacing(
                            verySmall: 16.0,
                            small: 20.0,
                            large: 24.0,
                          )),
                          
                          // Vivu Travel Logo
                          Container(
                            width: context.responsive(
                              verySmall: 120.0,
                              small: 180.0,
                              large: 240.0,
                            ),
                            height: context.responsive(
                              verySmall: 120.0,
                              small: 180.0,
                              large: 240.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                                verySmall: 30.0,
                                small: 40.0,
                                large: 120.0,
                              )),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                                verySmall: 30.0,
                                small: 40.0,
                                large: 120.0,
                              )),
                              child: Image.asset(
                                'assets/images/vivu_logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: context.responsiveSpacing(
                            verySmall: 16.0,
                            small: 20.0,
                            large: 24.0,
                          )),
                          
                          // Header
                          Column(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    verySmall: 22.0,
                                    small: 25.0,
                                    large: 28.0,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              
                              SizedBox(height: context.responsiveSpacing(
                                verySmall: 8.0,
                                small: 10.0,
                                large: 12.0,
                              )),
                              
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    verySmall: 12.0,
                                    small: 13.0,
                                    large: 14.0,
                                  ),
                                  color: const Color(0xFF757575),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      SizedBox(height: context.responsiveSpacing(
                        verySmall: 24.0,
                        small: 32.0,
                        large: 40.0,
                      )),
                      
                      // Content Section
                      child,
                      
                      SizedBox(height: context.responsiveSpacing(
                        verySmall: 24.0,
                        small: 32.0,
                        large: 40.0,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
