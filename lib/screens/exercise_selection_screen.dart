// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Exercise {
  final String name;
  final String animationPath;
  final String description;
  final String instructions;
  final String benefits;
  final List<String> musclesTargeted;
  final String difficulty;
  final String recommendedReps;
  final String caloriesBurned;

  Exercise({
    required this.name,
    required this.animationPath,
    required this.description,
    this.instructions = '',
    this.benefits = '',
    this.musclesTargeted = const [],
    this.difficulty = 'Medium',
    this.recommendedReps = '',
    this.caloriesBurned = '',
  });
}

class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({Key? key}) : super(key: key);

  @override
  _ExerciseSelectionScreenState createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  // List of exercises
  final List<Exercise> exercises = [
    Exercise(
      name: 'Frog Press',
      animationPath: 'assets/animation/FROG PRESS.json',
      description: 'A challenging core exercise that targets your lower abs and hip flexors.',
      instructions: '1. Lie on your back with knees bent and feet flat on the floor\n2. Place hands behind your head or at your sides\n3. Bring your knees toward your chest\n4. Press your legs out to the sides, like a frog\n5. Pull legs back in and repeat',
      benefits: 'Strengthens core muscles, improves hip flexibility, and enhances lower back stability.',
      musclesTargeted: ['Abs', 'Hip Flexors', 'Lower Back', 'Obliques'],
      difficulty: 'Medium',
      recommendedReps: '3 sets of 12-15 reps',
      caloriesBurned: '4-6 calories per minute',
    ),
    Exercise(
      name: 'Jumping Jacks',
      animationPath: 'assets/animation/JUMPING JACKS.json',
      description: 'A full-body cardio exercise that works your shoulders, arms, and legs.',
      instructions: '1. Stand with feet together and arms at sides\n2. Jump while spreading legs and raising arms above head\n3. Jump back to starting position\n4. Repeat at a quick pace',
      benefits: 'Improves cardiovascular health, increases stamina, burns calories, and enhances coordination.',
      musclesTargeted: ['Calves', 'Shoulders', 'Hip Abductors', 'Quads'],
      difficulty: 'Easy',
      recommendedReps: '3 sets of 30 seconds each',
      caloriesBurned: '8-12 calories per minute',
    ),
    Exercise(
      name: 'Lunges',
      animationPath: 'assets/animation/LUNGES.json',
      description: 'A lower body exercise that works your quadriceps, hamstrings, and glutes.',
      instructions: '1. Stand tall with feet hip-width apart\n2. Step forward with one leg\n3. Lower your hips until both knees are bent at 90 degrees\n4. Push back up and return to starting position\n5. Repeat with the other leg',
      benefits: 'Strengthens legs and glutes, improves balance and stability, and increases functional strength.',
      musclesTargeted: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves'],
      difficulty: 'Medium',
      recommendedReps: '3 sets of 10-12 reps per leg',
      caloriesBurned: '5-7 calories per minute',
    ),
    Exercise(
      name: 'Pull Ups',
      animationPath: 'assets/animation/pull ups.json',
      description: 'An upper body exercise that strengthens your back, shoulders, and arms.',
      instructions: '1. Grip a pull-up bar with palms facing away\n2. Hang with arms fully extended\n3. Pull yourself up until chin is above the bar\n4. Lower yourself with control\n5. Repeat',
      benefits: 'Builds upper body strength, improves grip strength, and develops back and arm muscles.',
      musclesTargeted: ['Latissimus Dorsi', 'Biceps', 'Shoulders', 'Forearms'],
      difficulty: 'Hard',
      recommendedReps: '3 sets of 5-10 reps',
      caloriesBurned: '6-10 calories per minute',
    ),
    Exercise(
      name: 'Push Ups',
      animationPath: 'assets/animation/push_ups.json',
      description: 'A classic exercise that targets your chest, shoulders, and triceps.',
      instructions: '1. Start in a plank position with hands shoulder-width apart\n2. Keep your body in a straight line\n3. Lower your body until elbows are at 90 degrees\n4. Push back up to the starting position\n5. Repeat',
      benefits: 'Strengthens chest, shoulders, and arms, improves core stability, and can be done anywhere.',
      musclesTargeted: ['Chest', 'Triceps', 'Shoulders', 'Core'],
      difficulty: 'Medium',
      recommendedReps: '3 sets of 10-20 reps',
      caloriesBurned: '5-8 calories per minute',
    ),
    Exercise(
      name: 'Seated Abs Circles',
      animationPath: 'assets/animation/SEATED ABS CIRCLES.json',
      description: 'A core-focused exercise that improves abdominal strength and stability.',
      instructions: '1. Sit on the floor with knees bent and feet flat\n2. Lean back slightly and lift feet off the floor\n3. Engage core and maintain balance\n4. Move upper body in circular motions\n5. Perform in both directions',
      benefits: 'Strengthens core muscles, improves stability, enhances balance, and targets obliques.',
      musclesTargeted: ['Rectus Abdominis', 'Obliques', 'Hip Flexors', 'Lower Back'],
      difficulty: 'Medium',
      recommendedReps: '3 sets of 10 circles in each direction',
      caloriesBurned: '4-6 calories per minute',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exercise Prediction',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Select an Exercise',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Search Exercises',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: exercises.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return _buildExerciseCard(exercise);
          },
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return GestureDetector(
      onTap: () => _showExerciseDetails(exercise),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise image
            Expanded(
              child: Stack(
                children: [
                  // Lottie animation
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: Colors.deepPurple.shade50,
                      child: Lottie.asset(
                        exercise.animationPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Difficulty badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(exercise.difficulty),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise.difficulty,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Exercise info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 14,
                        color: Colors.deepPurple.shade300,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          exercise.musclesTargeted.isNotEmpty
                              ? exercise.musclesTargeted.join(", ")
                              : 'Multiple muscles',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 12,
                          color: Colors.deepPurple.shade400,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Tap for details',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }

  void _showExerciseDetails(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),

              // Exercise animation
              Container(
                height: 240,
                color: Colors.deepPurple.shade50,
                child: Lottie.asset(
                  exercise.animationPath,
                  fit: BoxFit.contain,
                ),
              ),

              // Exercise info
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and difficulty tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(exercise.difficulty),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            exercise.difficulty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description section
                    _buildInfoSection(
                      title: 'Description',
                      content: exercise.description,
                      icon: Icons.info_outline,
                    ),

                    const SizedBox(height: 16),

                    // Instructions section
                    _buildInfoSection(
                      title: 'How to perform',
                      content: exercise.instructions,
                      icon: Icons.format_list_numbered,
                    ),

                    const SizedBox(height: 16),

                    // Benefits section
                    _buildInfoSection(
                      title: 'Benefits',
                      content: exercise.benefits,
                      icon: Icons.health_and_safety,
                    ),

                    const SizedBox(height: 16),

                    // Muscles targeted section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Muscles Targeted', Icons.fitness_center),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: exercise.musclesTargeted
                              .map(
                                (muscle) => Chip(
                                  backgroundColor: Colors.deepPurple.shade100,
                                  label: Text(
                                    muscle,
                                    style: TextStyle(
                                      color: Colors.deepPurple.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Training details row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            title: 'Recommended',
                            value: exercise.recommendedReps,
                            icon: Icons.repeat,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailCard(
                            title: 'Calories',
                            value: exercise.caloriesBurned,
                            icon: Icons.local_fire_department,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Learn more button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // You can add more detailed exercise info or tutorial here
                      },
                      icon: const Icon(Icons.info),
                      label: const Text('Learn More'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, icon),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        List<Exercise> filteredExercises = [];

        return StatefulBuilder(
          builder: (context, setState) {
            // Filter exercises based on search query
            filteredExercises = exercises.where((exercise) {
              return exercise.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  exercise.musclesTargeted.any(
                    (muscle) => muscle.toLowerCase().contains(searchQuery.toLowerCase()),
                  ) ||
                  exercise.difficulty.toLowerCase() == searchQuery.toLowerCase();
            }).toList();

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Search Exercises',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Search field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              autofocus: true,
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search exercises, muscles, difficulty...',
                                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Results
                    Expanded(
                      child: filteredExercises.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No exercises found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredExercises.length,
                              itemBuilder: (context, index) {
                                final exercise = filteredExercises[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.deepPurple.shade100,
                                      child: Icon(
                                        Icons.fitness_center,
                                        color: Colors.deepPurple.shade700,
                                      ),
                                    ),
                                    title: Text(exercise.name),
                                    subtitle: Text(exercise.musclesTargeted.join(', ')),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getDifficultyColor(exercise.difficulty),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        exercise.difficulty,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _showExerciseDetails(exercise);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 