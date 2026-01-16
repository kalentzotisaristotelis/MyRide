import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.speed, size: 100, color: Colors.deepOrange),
            SizedBox(height: 20),
            Text('Dashboard Stats Here'),
          ],
        ),
      ),
    );
  }
}