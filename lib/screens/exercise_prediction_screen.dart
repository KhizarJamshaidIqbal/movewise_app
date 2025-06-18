// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExercisePredictionScreen extends StatefulWidget {
  const ExercisePredictionScreen({Key? key}) : super(key: key);

  @override
  _ExercisePredictionScreenState createState() =>
      _ExercisePredictionScreenState();
}

class _ExercisePredictionScreenState extends State<ExercisePredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for all input fields
  final TextEditingController _shoulderAngleController =
      TextEditingController();
  final TextEditingController _elbowAngleController = TextEditingController();
  final TextEditingController _hipAngleController = TextEditingController();
  final TextEditingController _kneeAngleController = TextEditingController();
  final TextEditingController _ankleAngleController = TextEditingController();
  final TextEditingController _shoulderGroundAngleController =
      TextEditingController();
  final TextEditingController _elbowGroundAngleController =
      TextEditingController();
  final TextEditingController _hipGroundAngleController =
      TextEditingController();
  final TextEditingController _kneeGroundAngleController =
      TextEditingController();
  final TextEditingController _ankleGroundAngleController =
      TextEditingController();

  String _selectedSide = 'left';

  @override
  void dispose() {
    _shoulderAngleController.dispose();
    _elbowAngleController.dispose();
    _hipAngleController.dispose();
    _kneeAngleController.dispose();
    _ankleAngleController.dispose();
    _shoulderGroundAngleController.dispose();
    _elbowGroundAngleController.dispose();
    _hipGroundAngleController.dispose();
    _kneeGroundAngleController.dispose();
    _ankleGroundAngleController.dispose();
    super.dispose();
  }

  // Validator for angle fields
  String? _validateAngle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an angle value';
    }
    final double? angle = double.tryParse(value);
    if (angle == null) {
      return 'Please enter a valid number';
    }
    if (angle < 0 || angle > 360) {
      return 'Angle must be between 0 and 360 degrees';
    }
    return null;
  }

  // Build input field widget
  Widget _buildAngleField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          suffixText: '°',
        ),
        validator: _validateAngle,
      ),
    );
  }

  // API call function
  Future<void> _predictExercise() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> requestBody = {
        'Side': _selectedSide,
        'Shoulder_Angle': double.parse(_shoulderAngleController.text),
        'Elbow_Angle': double.parse(_elbowAngleController.text),
        'Hip_Angle': double.parse(_hipAngleController.text),
        'Knee_Angle': double.parse(_kneeAngleController.text),
        'Ankle_Angle': double.parse(_ankleAngleController.text),
        'Shoulder_Ground_Angle': double.parse(
          _shoulderGroundAngleController.text,
        ),
        'Elbow_Ground_Angle': double.parse(_elbowGroundAngleController.text),
        'Hip_Ground_Angle': double.parse(_hipGroundAngleController.text),
        'Knee_Ground_Angle': double.parse(_kneeGroundAngleController.text),
        'Ankle_Ground_Angle': double.parse(_ankleGroundAngleController.text),
      };

      final response = await http
          .post(
            Uri.parse(
              'https://fastapi-example-production-49ab.up.railway.app/predict',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check if the server is running',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Save successful prediction to Firestore
        await _savePredictionToFirestore(
          responseData['predicted_exercise'],
          responseData['confidence'],
          requestBody,
        );

        _showPredictionDialog(
          true,
          responseData['predicted_exercise'],
          responseData['confidence'],
          responseData['status'],
        );
      } else {
        _showPredictionDialog(
          false,
          'Failed to get prediction',
          null,
          'Error ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      _showPredictionDialog(
        false,
        'Network Error',
        null,
        'Unable to connect to the server.\nPlease ensure the FastAPI server is running on https://fastapi-example-production-49ab.up.railway.app\nDetails: $e',
      );
    } on FormatException catch (e) {
      _showPredictionDialog(
        false,
        'Data Error',
        null,
        'Invalid response format from server.\nDetails: $e',
      );
    } catch (e) {
      _showPredictionDialog(false, 'Unexpected Error', null, '$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save prediction result to Firestore
  Future<void> _savePredictionToFirestore(
    String exercise,
    dynamic confidence,
    Map<String, dynamic> inputData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User not authenticated, skipping Firestore save');
        return;
      }

      await _firestore.collection('exercise_predictions').add({
        'userId': user.uid,
        'exercise': exercise,
        'confidence': confidence,
        'side': inputData['Side'],
        'shoulderAngle': inputData['Shoulder_Angle'],
        'elbowAngle': inputData['Elbow_Angle'],
        'hipAngle': inputData['Hip_Angle'],
        'kneeAngle': inputData['Knee_Angle'],
        'ankleAngle': inputData['Ankle_Angle'],
        'shoulderGroundAngle': inputData['Shoulder_Ground_Angle'],
        'elbowGroundAngle': inputData['Elbow_Ground_Angle'],
        'hipGroundAngle': inputData['Hip_Ground_Angle'],
        'kneeGroundAngle': inputData['Knee_Ground_Angle'],
        'ankleGroundAngle': inputData['Ankle_Ground_Angle'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Prediction saved to Firestore successfully');
    } catch (e) {
      print('Error saving prediction to Firestore: $e');
      // Don't show error to user as this is a background operation
    }
  }

  // Show prediction result in a dialog
  void _showPredictionDialog(
    bool isSuccess,
    String exercise,
    dynamic confidence,
    String status,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors:
                    isSuccess
                        ? [Colors.green.shade50, Colors.green.shade100]
                        : [Colors.red.shade50, Colors.red.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess ? Colors.green : Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: (isSuccess ? Colors.green : Colors.red)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    isSuccess ? Icons.fitness_center : Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  isSuccess ? 'Prediction Result' : 'Prediction Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                // Content
                if (isSuccess) ...[
                  _buildResultRow(
                    'Exercise',
                    exercise,
                    Icons.sports_gymnastics,
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow(
                    'Confidence',
                    '${confidence}%',
                    Icons.analytics,
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow('Status', status, Icons.check_circle),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              exercise,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isSuccess)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _clearForm();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('New Prediction'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget for result rows
  Widget _buildResultRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Clear form function
  void _clearForm() {
    _shoulderAngleController.clear();
    _elbowAngleController.clear();
    _hipAngleController.clear();
    _kneeAngleController.clear();
    _ankleAngleController.clear();
    _shoulderGroundAngleController.clear();
    _elbowGroundAngleController.clear();
    _hipGroundAngleController.clear();
    _kneeGroundAngleController.clear();
    _ankleGroundAngleController.clear();
    setState(() {
      _selectedSide = 'left';
    });
  }

  // Fill sample data for testing
  void _fillSampleData() {
    _shoulderAngleController.text = '10.64';
    _elbowAngleController.text = '174.47';
    _hipAngleController.text = '174.79';
    _kneeAngleController.text = '175.00';
    _ankleAngleController.text = '180.00';
    _shoulderGroundAngleController.text = '15.50';
    _elbowGroundAngleController.text = '25.30';
    _hipGroundAngleController.text = '45.20';
    _kneeGroundAngleController.text = '90.15';
    _ankleGroundAngleController.text = '95.75';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Prediction'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _fillSampleData,
            tooltip: 'Fill Sample Data',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Server Status Info Card
                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Make sure your FastAPI server is running on https://fastapi-example-production-49ab.up.railway.app',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exercise Angle Measurements',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Side selection
                        Text(
                          'Side:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Left'),
                                value: 'left',
                                groupValue: _selectedSide,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSide = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Right'),
                                value: 'right',
                                groupValue: _selectedSide,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSide = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Body Angles Section
                        Text(
                          'Body Angles',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.deepPurple),
                        ),
                        _buildAngleField(
                          label: 'Shoulder Angle',
                          controller: _shoulderAngleController,
                          hint: 'e.g., 10.64',
                        ),
                        _buildAngleField(
                          label: 'Elbow Angle',
                          controller: _elbowAngleController,
                          hint: 'e.g., 174.47',
                        ),
                        _buildAngleField(
                          label: 'Hip Angle',
                          controller: _hipAngleController,
                          hint: 'e.g., 174.79',
                        ),
                        _buildAngleField(
                          label: 'Knee Angle',
                          controller: _kneeAngleController,
                          hint: 'e.g., 175.00',
                        ),
                        _buildAngleField(
                          label: 'Ankle Angle',
                          controller: _ankleAngleController,
                          hint: 'e.g., 180.00',
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Ground Angles Section
                        Text(
                          'Ground Angles',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.deepPurple),
                        ),
                        _buildAngleField(
                          label: 'Shoulder Ground Angle',
                          controller: _shoulderGroundAngleController,
                          hint: 'e.g., 15.50',
                        ),
                        _buildAngleField(
                          label: 'Elbow Ground Angle',
                          controller: _elbowGroundAngleController,
                          hint: 'e.g., 25.30',
                        ),
                        _buildAngleField(
                          label: 'Hip Ground Angle',
                          controller: _hipGroundAngleController,
                          hint: 'e.g., 45.20',
                        ),
                        _buildAngleField(
                          label: 'Knee Ground Angle',
                          controller: _kneeGroundAngleController,
                          hint: 'e.g., 90.15',
                        ),
                        _buildAngleField(
                          label: 'Ankle Ground Angle',
                          controller: _ankleGroundAngleController,
                          hint: 'e.g., 95.75',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Predict Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _predictExercise,
                    child:
                        _isLoading
                            ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Predicting...'),
                              ],
                            )
                            : const Text(
                              'Predict Exercise',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
