import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WorkoutStatisticsCard extends StatelessWidget {
  final bool isDashboard;

  const WorkoutStatisticsCard({Key? key, this.isDashboard = true})
    : super(key: key);

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<Map<String, dynamic>> _getWorkoutStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return _getEmptyStats();
      }

      final predictions =
          await _firestore
              .collection('exercise_predictions')
              .where('userId', isEqualTo: user.uid)
              .get();

      if (predictions.docs.isEmpty) {
        return _getEmptyStats();
      }

      // Calculate statistics
      final exerciseCount = <String, int>{};
      final bodyPartFocus = <String, int>{};
      double totalConfidence = 0.0;
      int totalPredictions = predictions.docs.length;
      final Map<String, List<String>> dateToExercises = {};

      // For streak calculation
      final allDates = <DateTime>[];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var doc in predictions.docs) {
        final data = doc.data();
        final exercise = data['exercise'] as String? ?? 'Unknown';
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
        final timestamp = data['timestamp'] as Timestamp?;
        final side = (data['side'] as String?)?.toLowerCase() ?? 'unknown';

        // Count exercises
        exerciseCount[exercise] = (exerciseCount[exercise] ?? 0) + 1;
        totalConfidence += confidence;

        // Track body parts based on exercise
        String bodyPart = _getBodyPartForExercise(exercise);
        bodyPartFocus[bodyPart] = (bodyPartFocus[bodyPart] ?? 0) + 1;

        if (timestamp != null) {
          final date = timestamp.toDate();
          final dateObj = DateTime(date.year, date.month, date.day);
          allDates.add(dateObj);

          // Track exercises by date
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          dateToExercises.putIfAbsent(dateKey, () => []);
          if (!dateToExercises[dateKey]!.contains(exercise)) {
            dateToExercises[dateKey]!.add(exercise);
          }
        }
      }

      // Find favorite exercise
      String favoriteExercise = 'None';
      int maxCount = 0;
      exerciseCount.forEach((exercise, count) {
        if (count > maxCount) {
          maxCount = count;
          favoriteExercise = exercise;
        }
      });

      // Find most focused body part
      String topBodyPart = 'None';
      maxCount = 0;
      bodyPartFocus.forEach((bodyPart, count) {
        if (count > maxCount) {
          maxCount = count;
          topBodyPart = bodyPart;
        }
      });

      // Calculate streak
      int currentStreak = 0;
      if (allDates.isNotEmpty) {
        allDates.sort((a, b) => b.compareTo(a)); // Sort in descending order

        // Check if worked out today
        bool workedOutToday = allDates.any(
          (date) =>
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day,
        );

        if (workedOutToday) {
          currentStreak = 1;
          var checkDate = today.subtract(const Duration(days: 1));

          while (allDates.any(
            (date) =>
                date.year == checkDate.year &&
                date.month == checkDate.month &&
                date.day == checkDate.day,
          )) {
            currentStreak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          }
        } else {
          // Check if worked out yesterday to continue streak
          var yesterday = today.subtract(const Duration(days: 1));
          bool workedOutYesterday = allDates.any(
            (date) =>
                date.year == yesterday.year &&
                date.month == yesterday.month &&
                date.day == yesterday.day,
          );

          if (workedOutYesterday) {
            currentStreak = 1;
            var checkDate = yesterday.subtract(const Duration(days: 1));

            while (allDates.any(
              (date) =>
                  date.year == checkDate.year &&
                  date.month == checkDate.month &&
                  date.day == checkDate.day,
            )) {
              currentStreak++;
              checkDate = checkDate.subtract(const Duration(days: 1));
            }
          }
        }
      }

      // Calculate consistency (percentage of days worked out in the last 7 days)
      int daysWorkedOutLastWeek = 0;
      final Set<String> lastSevenDays = {};

      for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        lastSevenDays.add(dateKey);
      }

      for (String dateKey in dateToExercises.keys) {
        if (lastSevenDays.contains(dateKey)) {
          daysWorkedOutLastWeek++;
        }
      }

      final consistency = daysWorkedOutLastWeek * 100 / 7;

      return {
        'totalWorkouts': dateToExercises.length,
        'totalExercises': exerciseCount.length,
        'avgAccuracy':
            totalPredictions > 0 ? totalConfidence / totalPredictions : 0.0,
        'favoriteExercise': favoriteExercise,
        'currentStreak': currentStreak,
        'consistency': consistency,
        'topBodyPart': topBodyPart,
        'totalPredictions': totalPredictions,
      };
    } catch (e) {
      print('Error getting workout statistics: $e');
      return _getEmptyStats();
    }
  }

  Map<String, dynamic> _getEmptyStats() {
    return {
      'totalWorkouts': 0,
      'totalExercises': 0,
      'avgAccuracy': 0.0,
      'favoriteExercise': 'None',
      'currentStreak': 0,
      'consistency': 0.0,
      'topBodyPart': 'None',
      'totalPredictions': 0,
    };
  }

  String _getBodyPartForExercise(String exercise) {
    final exerciseLower = exercise.toLowerCase();

    if (exerciseLower.contains('push') || exerciseLower.contains('bench')) {
      return 'Chest';
    } else if (exerciseLower.contains('pull') ||
        exerciseLower.contains('row')) {
      return 'Back';
    } else if (exerciseLower.contains('squat') ||
        exerciseLower.contains('lunge')) {
      return 'Legs';
    } else if (exerciseLower.contains('crunch') ||
        exerciseLower.contains('twist') ||
        exerciseLower.contains('sit') ||
        exerciseLower.contains('abs')) {
      return 'Core';
    } else if (exerciseLower.contains('curl') ||
        exerciseLower.contains('extension')) {
      return 'Arms';
    } else if (exerciseLower.contains('press') ||
        exerciseLower.contains('raise')) {
      return 'Shoulders';
    } else if (exerciseLower.contains('jump')) {
      return 'Cardio';
    } else {
      return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(isDashboard ? 16.0 : 0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 24),
                SizedBox(width: 8),
                const Text(
                  'Workout Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: _getWorkoutStatistics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }

                final stats = snapshot.data ?? _getEmptyStats();

                if (isDashboard) {
                  // Dashboard layout: 2x2 grid
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        icon: Icons.calendar_today,
                        value: '${stats['totalWorkouts']}',
                        label: 'Workout Days',
                      ),
                      _buildStatCard(
                        icon: Icons.local_fire_department,
                        value: '${stats['currentStreak']}',
                        label: 'Day Streak',
                      ),
                      _buildStatCard(
                        icon: Icons.trending_up,
                        value: '${stats['avgAccuracy'].toStringAsFixed(1)}%',
                        label: 'Avg Accuracy',
                      ),
                      _buildStatCard(
                        icon: Icons.favorite,
                        value: stats['favoriteExercise'],
                        label: 'Favorite',
                        isText: true,
                      ),
                    ],
                  );
                } else {
                  // Profile screen layout: 2x3 grid with more detailed stats
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        icon: Icons.calendar_today,
                        value: '${stats['totalWorkouts']}',
                        label: 'Workout Days',
                      ),
                      _buildStatCard(
                        icon: Icons.fitness_center,
                        value: '${stats['totalPredictions']}',
                        label: 'Total Exercises',
                      ),
                      _buildStatCard(
                        icon: Icons.local_fire_department,
                        value: '${stats['currentStreak']}',
                        label: 'Day Streak',
                      ),
                      _buildStatCard(
                        icon: Icons.repeat,
                        value: '${stats['consistency'].toStringAsFixed(0)}%',
                        label: 'Weekly Consistency',
                      ),
                      _buildStatCard(
                        icon: Icons.trending_up,
                        value: '${stats['avgAccuracy'].toStringAsFixed(1)}%',
                        label: 'Avg Accuracy',
                      ),
                      _buildStatCard(
                        icon: Icons.favorite,
                        value: stats['favoriteExercise'],
                        label: 'Favorite',
                        isText: true,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    bool isText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isText ? 12 : 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: isText ? 1 : 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
