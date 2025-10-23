import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen.dart';
import 'calculator.dart';

class InsidePage extends StatefulWidget {
  const InsidePage({super.key});

  @override
  State<InsidePage> createState() => _InsidePageState();
}

class _InsidePageState extends State<InsidePage> {
  int _currentIndex = 0;

  final pages = [
    const DashboardPage(),
    // Center(child: Text("Tab Kosong", style: TextStyle(fontSize: 20))),
    const CalculatorPage(),
    Scaffold(

      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 200,

            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:[
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                ],
              ) 
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                  Image.network(
                    'https://i.pinimg.com/736x/00/48/6e/00486e6443178ef5c1558e5c3dee7e92.jpg',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    const HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.browse_gallery_outlined),
            label: 'Gallery',
          ), 
          NavigationDestination(
            icon: Icon(Icons.data_array_outlined),
            label: 'Data',
          ),
        ],
      ),
    );
  }
}


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('This is your main dashboard screen.'),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                subtitle: const Text('View and edit your profile'),
                onTap: () {
                  // Navigate to profile page
                  
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.settings_outlined), 
                title: const Text('Gallery'),
                subtitle: const Text('App preferences and notifications'),
                onTap: () {},
              ),
            ),
            
          ],
        ),
      ),
    );
  }


  
}