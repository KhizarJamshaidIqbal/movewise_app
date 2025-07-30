import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_page_route.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  bool _isLastPage = false;
  late AnimationController _animationController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Track Your Workouts',
      description:
          'Monitor your exercises and track your fitness progress with our intelligent workout tracker.',
      animationPath: 'assets/animation/push_ups.json',
      backgroundColor: Colors.deepPurple.shade600,
      secondaryColor: Colors.deepPurple.shade300,
      accentColor: Colors.deepPurple.shade800,
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'AI Powered Analysis',
      description:
          'Our advanced AI recognizes your exercises and provides real-time feedback on your form.',
      animationPath: 'assets/animation/JUMPING JACKS.json',
      backgroundColor: Colors.blue.shade600,
      secondaryColor: Colors.blue.shade400,
      accentColor: Colors.blue.shade800,
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'Diverse Exercise Library',
      description:
          'Access a wide range of exercises and personalized workout plans for all fitness levels.',
      animationPath: 'assets/animation/LUNGES.json',
      backgroundColor: Colors.orange.shade600,
      secondaryColor: Colors.orange.shade400,
      accentColor: Colors.orange.shade800,
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'Ready to Move Wise?',
      description:
          'Sign up now and start your fitness journey with personalized exercise guidance.',
      animationPath: 'assets/animation/pull ups.json',
      backgroundColor: Colors.green.shade600,
      secondaryColor: Colors.green.shade400,
      accentColor: Colors.green.shade800,
      textColor: Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
        _animationController.forward(from: 0.0);
      }
    });

    _animationController.forward();
  }

  void _markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      debugPrint('✅ ONBOARDING: Successfully marked onboarding as complete');
    } catch (e) {
      debugPrint('❌ ONBOARDING: SharedPreferences error: $e');
      // Continue with navigation even if preferences can't be saved
    }
  }

  // Utility method for testing - call this to reset onboarding flag
  static Future<void> resetOnboardingFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', false);
      debugPrint('🔄 ONBOARDING: Reset onboarding flag for testing');
    } catch (e) {
      debugPrint('❌ ONBOARDING: Error resetting flag: $e');
    }
  }

  void _navigateToLogin() {
    _markOnboardingComplete();
    debugPrint('🔄 ONBOARDING: Navigating to login screen');
    Navigator.of(
      context,
    ).pushReplacement(CustomPageRoute(child: const LoginScreen()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background based on current page
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  _pages[_currentPage].backgroundColor,
                  _pages[_currentPage].secondaryColor,
                ],
              ),
            ),
          ),

          // Decorative background patterns
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                color: _pages[_currentPage].accentColor,
              ),
            ),
          ),

          // Page View with enhanced animations
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == _pages.length - 1;
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _animationController.drive(
                  CurveTween(curve: Curves.easeOut),
                ),
                child: _pages[index],
              );
            },
          ),

          // Top skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isLastPage ? 0.0 : 1.0,
              child: ElevatedButton(
                onPressed: _isLastPage ? null : _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
            ),
          ),

          // Bottom navigation buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: _pages[_currentPage].textColor,
                      dotColor: _pages[_currentPage].textColor.withOpacity(0.4),
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Next/Start button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _isLastPage
                              ? _navigateToLogin
                              : () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _pages[_currentPage].backgroundColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLastPage ? 'Get Started' : 'Next',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _pages[_currentPage].backgroundColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _isLastPage ? Icons.login : Icons.arrow_forward,
                            color: _pages[_currentPage].backgroundColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    // Draw circular patterns
    for (int i = 0; i < 20; i++) {
      final radius = (size.width * 0.1) + (i * 20);
      final opacity = 0.05 - (i * 0.002);
      if (opacity <= 0) continue;

      paint.color = color.withOpacity(opacity > 0 ? opacity : 0.01);
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint,
      );
    }

    // Draw a few random shapes
    for (int i = 0; i < 10; i++) {
      final rect = Rect.fromLTWH(
        i * size.width / 12,
        size.height - (i * size.height / 15) - 100,
        size.width / 8,
        size.height / 8,
      );
      canvas.drawOval(rect, paint..color = color.withOpacity(0.03));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String animationPath;
  final Color backgroundColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color textColor;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.animationPath,
    required this.backgroundColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: MediaQuery.of(context).padding.bottom + 120,
        left: 24.0,
        right: 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation with enhanced container
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(140),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Hero(
              tag: 'animation-$animationPath',
              child: Lottie.asset(animationPath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 40),

          // Title with enhanced style
          Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Description with enhanced style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 18,
                color: textColor.withOpacity(0.9),
                height: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
