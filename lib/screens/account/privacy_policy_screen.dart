import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.shade100,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.deepPurple.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade800,
                            ),
                          ),
                          Text(
                            'Your privacy matters to us',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.privacy_tip,
                        color: Colors.deepPurple.shade700,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Information We Collect',
                        'We collect information you provide directly to us, such as when you create an account, use our exercise prediction features, or contact us for support.',
                        Icons.info_outline,
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSection(
                        'How We Use Your Information',
                        'We use the information we collect to provide, maintain, and improve our services, including exercise predictions and workout tracking.',
                        Icons.settings,
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSection(
                        'Data Security',
                        'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                        Icons.security,
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSection(
                        'Exercise Data',
                        'Your exercise predictions and workout data are stored securely and used only to improve your fitness experience and provide personalized recommendations.',
                        Icons.fitness_center,
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSection(
                        'Third-Party Services',
                        'We may use third-party services like Firebase for authentication and data storage. These services have their own privacy policies.',
                        Icons.cloud,
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSection(
                        'Your Rights',
                        'You have the right to access, update, or delete your personal information. You can also opt out of certain communications.',
                        Icons.account_circle,
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSection(
                        'Contact Us',
                        'If you have any questions about this Privacy Policy, please contact us at privacy@movewise.com or through the Help & Support section.',
                        Icons.contact_support,
                      ),
                      const SizedBox(height: 40),
                      
                      // Last Updated
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.deepPurple.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.update,
                              color: Colors.deepPurple.shade600,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last Updated',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'December 2024',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.deepPurple.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}