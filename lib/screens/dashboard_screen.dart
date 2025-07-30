// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_prediction_screen.dart';
import 'exercise_prediction_welcome_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../widgets/workout_statistics_card.dart';
import '../widgets/modern_bottom_nav.dart';
import '../screens/recent_predictions_screen.dart';
import '../widgets/custom_page_route.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _pageTransitionController;

  @override
  void initState() {
    super.initState();
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  // Build pages so that we can pass the userName to HomeContent.
  List<Widget> _buildPages(String userName) {
    return [
      FadeTransition(
        opacity: CurvedAnimation(
          parent: _pageTransitionController,
          curve: Curves.easeInOut,
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _pageTransitionController,
              curve: Curves.easeOut,
            ),
          ),
          child: HomeContent(userName: userName),
        ),
      ),
      const ExercisePredictionWelcomeScreen(),
      const HistoryScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _pageTransitionController.reset();
      _selectedIndex = index;
      _pageTransitionController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(widget.userName);
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String userName;
  const HomeContent({Key? key, required this.userName}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  // Animation controller for staggered animations
  late AnimationController _animationController;
  late Animation<double> _profileCardAnimation;
  late Animation<double> _motivationCardAnimation;
  late Animation<double> _statsCardAnimation;
  late Animation<double> _workoutsAnimation;
  late Animation<double> _predictionsAnimation;

  // Current user name from Firestore
  String _currentUserName = 'User';
  bool _isLoadingUserName = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Define staggered animations for each section
    _profileCardAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _motivationCardAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );

    _statsCardAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    _workoutsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );

    _predictionsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );

    // Initialize with the passed userName as fallback
    _currentUserName = widget.userName;

    // Fetch current user name from Firestore
    _fetchCurrentUserName();

    // Start animation
    _animationController.forward();

    // Listen for when user returns to this screen (e.g., from profile)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchCurrentUserName();
      }
    });
  }

  // Fetch the most current user name from Firestore
  Future<void> _fetchCurrentUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final newUserName = userData['name'] ?? widget.userName;

          if (mounted && newUserName != _currentUserName) {
            setState(() {
              _currentUserName = newUserName;
              _isLoadingUserName = false;
            });
            debugPrint(
              '📝 DASHBOARD: Updated user name from Firestore: $newUserName',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ DASHBOARD: Error fetching user name: $e');
      if (mounted) {
        setState(() {
          _isLoadingUserName = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user name when returning to this screen
    _fetchCurrentUserName();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Dummy upcoming workouts data.
  final List<Map<String, dynamic>> upcomingWorkouts = const [
    {"title": "Pushups", "time": "10:00 AM"},
    {"title": "Pullups", "time": "11:00 AM"},
    {"title": "Russian Twists", "time": "12:00 PM"},
  ];

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Get predictions stream with fallback for index error
  Stream<QuerySnapshot> _getPredictionsStream() {
    try {
      return _firestore
          .collection('exercise_predictions')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .limit(5)
          .snapshots();
    } catch (e) {
      // Just return the basic stream if there's an error
      return _firestore
          .collection('exercise_predictions')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .snapshots();
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getExerciseIcon(String exercise) {
    switch (exercise.toLowerCase()) {
      case 'pushups':
      case 'push ups':
        return Icons.fitness_center;
      case 'pullups':
      case 'pull ups':
        return Icons.accessibility_new;
      case 'jumping jacks':
        return Icons.directions_run;
      case 'squats':
        return Icons.airline_seat_legroom_reduced;
      case 'lunges':
        return Icons.directions_walk;
      default:
        return Icons.sports_gymnastics;
    }
  }

  Color _getExerciseColor(String exercise) {
    switch (exercise.toLowerCase()) {
      case 'pushups':
      case 'push ups':
        return Colors.red;
      case 'pullups':
      case 'pull ups':
        return Colors.blue;
      case 'jumping jacks':
        return Colors.green;
      case 'squats':
        return Colors.orange;
      case 'lunges':
        return Colors.purple;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Enhanced User Profile Section with animation
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(_profileCardAnimation),
            child: FadeTransition(
              opacity: _profileCardAnimation,
              child: _buildProfileCard(),
            ),
          ),

          // Animated Motivational Banner
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(_motivationCardAnimation),
            child: FadeTransition(
              opacity: _motivationCardAnimation,
              child: _buildMotivationalBanner(),
            ),
          ),

          const SizedBox(height: 16),

          // Workout Statistics Card with animation
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(_statsCardAnimation),
            child: FadeTransition(
              opacity: _statsCardAnimation,
              child: const WorkoutStatisticsCard(),
            ),
          ),

          const SizedBox(height: 16),

          // Upcoming Workouts Section with animation
          FadeTransition(
            opacity: _workoutsAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_workoutsAnimation),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: const [
                        Text(
                          "Previous Workouts",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.fitness_center,
                          size: 20,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Workout cards list
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = upcomingWorkouts[index];
                        // Add staggered animation to each workout card
                        return AnimatedBuilder(
                          animation: _workoutsAnimation,
                          builder: (context, child) {
                            final delay = 0.2 * index;
                            final value = math.max(
                              0.0,
                              math.min(
                                1.0,
                                (_workoutsAnimation.value - delay) * 3,
                              ),
                            );
                            return Transform.translate(
                              offset: Offset(20 * (1 - value), 0),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: _buildWorkoutCard(workout),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Previous Workouts Preview Section with animation
          FadeTransition(
            opacity: _predictionsAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_predictionsAnimation),
              child: _buildRecentPredictionsSection(),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Profile card widget
  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade200,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Animated avatar container
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.deepPurple[700]!,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      _currentUserName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready for your next workout?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildAnimatedSettingsButton(),
          ],
        ),
      ),
    );
  }

  // Animated settings button
  Widget _buildAnimatedSettingsButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsScreen(userName: _currentUserName),
            ),
          );
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 2 * math.pi),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.rotate(angle: value, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  // Motivational banner widget
  Widget _buildMotivationalBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.pink.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.elasticInOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Animated text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Motivated!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Push yourself, because no one else is going to do it for you.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Workout card widget
  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return GestureDetector(
      onTap: () {
        // Show a small animation on tap
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${workout['title']} workout selected'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade200,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade100.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                workout['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    workout['time'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Recent predictions section widget
  Widget _buildRecentPredictionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.deepPurple[700]!,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Recent Exercise Predictions",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      5 * math.sin(_animationController.value * 2 * math.pi),
                      0,
                    ),
                    child: child,
                  );
                },
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      CustomPageRoute(child: const RecentPredictionsScreen()),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.deepPurple[700]!,
                  ),
                  label: Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.deepPurple[700]!,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Predictions stream builder
          SizedBox(
            height: 180,
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPredictionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple.shade300,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading predictions...',
                          style: TextStyle(
                            color: Colors.deepPurple.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade400,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading predictions',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animation/Welcome.json',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No predictions yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start predicting exercises to see history',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort documents by timestamp
                final docs = snapshot.data!.docs;
                docs.sort((a, b) {
                  final aTimestamp =
                      (a.data() as Map<String, dynamic>)['timestamp']
                          as Timestamp?;
                  final bTimestamp =
                      (b.data() as Map<String, dynamic>)['timestamp']
                          as Timestamp?;
                  if (aTimestamp == null || bTimestamp == null) return 0;
                  return bTimestamp.compareTo(aTimestamp);
                });

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // Add staggered animation to each prediction card
                    return AnimatedBuilder(
                      animation: _predictionsAnimation,
                      builder: (context, child) {
                        final delay = 0.1 * index;
                        final value = math.max(
                          0.0,
                          math.min(
                            1.0,
                            (_predictionsAnimation.value - delay) * 3,
                          ),
                        );
                        return Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _buildPredictionCard(docs[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Prediction card widget
  Widget _buildPredictionCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final exercise = data['exercise'] ?? 'Unknown';
    final confidence = data['confidence']?.toString() ?? '0';
    final side = data['side'] ?? 'Unknown';
    final timestamp =
        (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

    final exerciseColor = _getExerciseColor(exercise);
    final exerciseIcon = _getExerciseIcon(exercise);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, exerciseColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: exerciseColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: exerciseColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and exercise name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: exerciseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(exerciseIcon, color: exerciseColor, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: exerciseColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Confidence and side info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.analytics,
                        size: 12,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${confidence}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        side.toLowerCase() == 'left'
                            ? Colors.blue.shade100
                            : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    side.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          side.toLowerCase() == 'left'
                              ? Colors.blue.shade700
                              : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Timestamp
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Text(
              '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
