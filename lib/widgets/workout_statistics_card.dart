import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutStatisticsCard extends StatelessWidget {
  const WorkoutStatisticsCard({Key? key}) : super(key: key);

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<Map<String, dynamic>> _getWorkoutStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'totalWorkouts': 0,
          'totalExercises': 0,
          'avgConfidence': 0.0,
          'favoriteExercise': 'None',
        };
      }

      final predictions = await _firestore
          .collection('exercise_predictions')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (predictions.docs.isEmpty) {
        return {
          'totalWorkouts': 0,
          'totalExercises': 0,
          'avgConfidence': 0.0,
          'favoriteExercise': 'None',
        };
      }

      // Calculate statistics
      final exerciseCount = <String, int>{};
      double totalConfidence = 0.0;
      int totalPredictions = predictions.docs.length;

      for (var doc in predictions.docs) {
        final data = doc.data();
        final exercise = data['exercise'] as String? ?? 'Unknown';
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;

        exerciseCount[exercise] = (exerciseCount[exercise] ?? 0) + 1;
        totalConfidence += confidence;
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

      // Group by date to count unique workout sessions
      final workoutDates = <String>{};
      for (var doc in predictions.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final dateKey = '${date.year}-${date.month}-${date.day}';
          workoutDates.add(dateKey);
        }
      }

      return {
        'totalWorkouts': workoutDates.length,
        'totalExercises': exerciseCount.length,
        'avgConfidence': totalPredictions > 0 ? (totalConfidence / totalPredictions) * 100 : 0.0,
        'favoriteExercise': favoriteExercise,
      };
    } catch (e) {
      return {
        'totalWorkouts': 0,
        'totalExercises': 0,
        'avgConfidence': 0.0,
        'favoriteExercise': 'None',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade600,
            Colors.deepPurple.shade400,
          ],
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
            const Text(
              'Workout Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: _getWorkoutStatistics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                final stats = snapshot.data ?? {
                  'totalWorkouts': 0,
                  'totalExercises': 0,
                  'avgConfidence': 0.0,
                  'favoriteExercise': 'None',
                };

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      icon: Icons.fitness_center,
                      value: '${stats['totalWorkouts']}',
                      label: 'Total Workouts',
                    ),
                    _buildStatCard(
                      icon: Icons.sports_gymnastics,
                      value: '${stats['totalExercises']}',
                      label: 'Exercises',
                    ),
                    _buildStatCard(
                      icon: Icons.trending_up,
                      value: '${stats['avgConfidence'].toStringAsFixed(1)}%',
                      label: 'Avg Confidence',
                    ),
                    _buildStatCard(
                      icon: Icons.favorite,
                      value: stats['favoriteExercise'],
                      label: 'Favorite',
                      isText: true,
                    ),
                  ],
                );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isText ? 14 : 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: isText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}