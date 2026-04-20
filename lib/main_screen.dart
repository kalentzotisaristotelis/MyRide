import 'package:flutter/material.dart';
import 'features/dashboard/view/dashboard_screen.dart';
import 'features/garage/view/garage_screen.dart';
import 'features/profile/view/profile_screen.dart';
import 'features/rides/view/rides_screen.dart'; // ΝΕΟ IMPORT

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Αυτή η μεταβλητή θυμάται ποια καρτέλα βλέπουμε
  int _selectedIndex = 0;

  // Η λίστα με τις οθόνες μας (Προσθέσαμε το RidesScreen στη θέση 1)
  final List<Widget> _screens = [
    const DashboardScreen(), // 0
    const RidesScreen(),     // 1 - ΝΕΑ ΚΑΡΤΕΛΑ
    const GarageScreen(),    // 2
    const ProfileScreen(),   // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Εδώ εμφανίζουμε την οθόνη ανάλογα με τον αριθμό _selectedIndex
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),

      // Η κάτω μπάρα ενημερωμένη με 4 προορισμούς
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined), // Εικονίδιο για βόλτες
            selectedIcon: Icon(Icons.map),
            label: 'Rides',
          ),
          NavigationDestination(
            icon: Icon(Icons.two_wheeler_outlined),
            selectedIcon: Icon(Icons.two_wheeler),
            label: 'Garage',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}