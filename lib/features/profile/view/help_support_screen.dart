import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Popular Topics'),
          _buildSupportCard(
            context,
            icon: Icons.help_outline,
            title: 'How to organize a ride',
            subtitle: 'Learn the basics of creating events.',
          ),
          _buildSupportCard(
            context,
            icon: Icons.security,
            title: 'Account Security',
            subtitle: 'Manage your password and privacy.',
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Contact Us'),
          _buildSupportCard(
            context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@myride.com',
          ),
          _buildSupportCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Talk to our team (9:00 - 17:00)',
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('App Information'),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('MyRide Version 2.4.0', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Made with ❤️ for the motorcycle community', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          // Εδώ μπορείς να βάλεις μια ενέργεια
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title...')),
          );
        },
      ),
    );
  }
}