import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate after the animation completes
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('⏰ SPLASH: Animation complete, checking navigation path');
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    bool hasSeenOnboarding = false;
    User? user;

    try {
      // Try to get SharedPreferences data, but handle potential exceptions
      final prefs = await SharedPreferences.getInstance();
      hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      debugPrint('🔍 SPLASH: hasSeenOnboarding = $hasSeenOnboarding');
    } catch (e) {
      // If there's an error with SharedPreferences, use user login status as fallback
      debugPrint('❌ SPLASH: SharedPreferences error: $e');
      // If user exists, assume they've seen onboarding (since they registered/logged in before)
      // If no user, assume they haven't seen onboarding
      hasSeenOnboarding =
          false; // Will be handled by priority-based logic below
      debugPrint(
        '🔄 SPLASH: Using fallback logic due to SharedPreferences error',
      );
    }

    try {
      // Try to get current user from Firebase Auth
      user = FirebaseAuth.instance.currentUser;
      debugPrint('🔍 SPLASH: user = ${user?.uid ?? 'null'}');
    } catch (e) {
      // If there's an error with Firebase Auth, assume user is not logged in
      debugPrint('❌ SPLASH: Firebase Auth error: $e');
      user = null;
    }

    if (!mounted) return;

    // Navigate to appropriate screen with priority-based logic
    debugPrint(
      '🔄 SPLASH: Navigation decision - hasSeenOnboarding: $hasSeenOnboarding, user: ${user != null}',
    );

    /* NAVIGATION PRIORITY LOGIC:
     * 1. If user is logged in → Dashboard (regardless of onboarding/SharedPreferences status)
     * 2. If no user + hasn't seen onboarding → Onboarding
     * 3. If no user + has seen onboarding → Login
     */

    // Priority 1: If user is logged in, go to dashboard (regardless of onboarding status)
    if (user != null) {
      debugPrint(
        '👤 SPLASH: User already logged in - going directly to dashboard',
      );

      // Get user name from Firestore (most current data)
      String userName = 'User';
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userName = userData['name'] ?? user.displayName ?? 'User';
          debugPrint(
            '📝 SPLASH: Fetched current user name from Firestore: $userName',
          );
        } else {
          userName = user.displayName ?? 'User';
          debugPrint(
            '⚠️ SPLASH: User document not found, using Firebase Auth displayName: $userName',
          );
        }
      } catch (e) {
        userName = user.displayName ?? 'User';
        debugPrint(
          '❌ SPLASH: Error fetching user name from Firestore: $e, using fallback: $userName',
        );
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  DashboardScreen(userName: userName),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeOutCubic;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
    // Priority 2: If no user and hasn't seen onboarding, show onboarding
    else if (!hasSeenOnboarding) {
      debugPrint('📱 SPLASH: First time user - showing onboarding');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeOutCubic;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
    // Priority 3: If no user and has seen onboarding, show login
    else {
      debugPrint('🔐 SPLASH: No user logged in - showing login');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeOutCubic;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  // Debug method to reset app state (for testing)
  static Future<void> resetAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      debugPrint(
        '🔄 DEBUG: App state reset - cleared SharedPreferences and signed out user',
      );
    } catch (e) {
      debugPrint('❌ DEBUG: Error resetting app state: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        Colors.deepPurple.shade900,
                        Colors.deepPurple.shade800,
                        _backgroundAnimation.value,
                      )!,
                      Color.lerp(
                        Colors.deepPurple.shade800,
                        Colors.deepPurple.shade500,
                        _backgroundAnimation.value,
                      )!,
                      Color.lerp(
                        Colors.deepPurple.shade600,
                        Colors.deepPurple.shade300,
                        _backgroundAnimation.value,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Background decorative elements
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value * 0.2,
                  child: CustomPaint(
                    painter: BackgroundPainter(_controller.value),
                  ),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon with animations
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // App name with enhanced animations
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black26,
                                offset: Offset(0, 4.0),
                              ),
                            ],
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText(
                                'MoveWise',
                                duration: const Duration(seconds: 2),
                                textStyle: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black26,
                                      offset: Offset(0, 4.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            isRepeatingAnimation: false,
                            totalRepeatCount: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tagline with enhanced animations
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _opacityAnimation.value * 0.9,
                        child: Text(
                          'Your AI Exercise Companion',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w300,
                            shadows: const [
                              Shadow(
                                blurRadius: 6.0,
                                color: Colors.black12,
                                offset: Offset(0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Enhanced loading indicator
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.9),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for decorative background elements
class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Draw decorative circles
    for (int i = 0; i < 8; i++) {
      final progress = (animationValue + i / 10) % 1.0;
      final radius = progress * size.width * 0.8;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint..color = Colors.white.withOpacity(0.1 * (1 - progress)),
      );
    }

    // Draw decorative lines
    const lineCount = 10;
    for (int i = 0; i < lineCount; i++) {
      final angle = (i / lineCount) * 2 * math.pi;
      final length = size.width * 0.4 * animationValue;
      final startX = size.width / 2 + math.cos(angle) * length * 0.5;
      final startY = size.height / 2 + math.sin(angle) * length * 0.5;
      final endX = size.width / 2 + math.cos(angle) * length;
      final endY = size.height / 2 + math.sin(angle) * length;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..color = Colors.white.withOpacity(0.05),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
