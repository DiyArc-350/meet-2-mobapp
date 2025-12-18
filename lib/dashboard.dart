import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen.dart';
import 'package:flutter_application_1/storage_list.dart';
import 'calculator.dart';
import 'movies_home_screen.dart';
import 'package:flutter_application_1/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'didi_home_screen.dart';
import 'qrcode_page.dart';
import 'profile_page.dart';

class InsidePage extends StatefulWidget {
  const InsidePage({super.key});

  @override
  State<InsidePage> createState() => _InsidePageState();

  static _InsidePageState? of(BuildContext context) {
    return context.findAncestorStateOfType<_InsidePageState>();
  }
}

class _InsidePageState extends State<InsidePage> {
  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final pages = [
    const DashboardPage(),
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
              ),
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
    const MoviesHomeScreen(),
    const DidiHomeScreen(),
    const StorageList(),
    const QRCodePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.calculate_outlined, 'Calculator'),
                _buildNavItem(2, Icons.browse_gallery_outlined, 'Gallery'),
                _buildNavItem(3, Icons.data_array_outlined, 'Data'),
                _buildNavItem(4, Icons.movie_outlined, 'Movies'),
                _buildNavItem(5, Icons.quiz_outlined, 'Quiz'),
                _buildNavItem(6, Icons.storage_outlined, 'Storage'),
                _buildNavItem(7, Icons.qr_code, 'QRCode'),
                _buildNavItem(8, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // batal
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // tutup dialog
              _logout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
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

              // Profile Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.person_outline, color: Colors.blue),
                  title: const Text('Profile'),
                  subtitle: const Text('View and edit your profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to profile page (index 8)
                    final insidePageState = InsidePage.of(context);
                    if (insidePageState != null) {
                      insidePageState.setIndex(8);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Gallery Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.browse_gallery_outlined,
                    color: Colors.green,
                  ),
                  title: const Text('Gallery'),
                  subtitle: const Text('Browse your photos and videos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Gallery tab (index 2)
                    final insidePageState = InsidePage.of(context);
                    if (insidePageState != null) {
                      insidePageState.setIndex(2);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Settings Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                    color: Colors.orange,
                  ),
                  title: const Text('Settings'),
                  subtitle: const Text('App preferences and notifications'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings page - Coming soon'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Storage Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.storage_outlined,
                    color: Colors.purple,
                  ),
                  title: const Text('Storage'),
                  subtitle: const Text('Manage your files and storage'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Storage tab (index 6)
                    final insidePageState = InsidePage.of(context);
                    if (insidePageState != null) {
                      insidePageState.setIndex(6);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Calculator Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.calculate_outlined,
                    color: Colors.red,
                  ),
                  title: const Text('Calculator'),
                  subtitle: const Text('Quick calculations and math tools'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Calculator tab (index 1)
                    final insidePageState = InsidePage.of(context);
                    if (insidePageState != null) {
                      insidePageState.setIndex(1);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Movies Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.movie_outlined,
                    color: Colors.indigo,
                  ),
                  title: const Text('Movies'),
                  subtitle: const Text('Browse movies and watch trailers'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Movies tab (index 4)
                    final insidePageState = InsidePage.of(context);
                    if (insidePageState != null) {
                      insidePageState.setIndex(4);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Quiz Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.quiz_outlined, color: Colors.teal),
                  title: const Text('Quiz'),
                  subtitle: const Text('Test your knowledge'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    final insidePageState = InsidePage.of(context);
                    if (insidePageState != null) {
                      insidePageState.setIndex(5);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Data Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.data_array_outlined,
                    color: Colors.cyan,
                  ),
                  title: const Text('Data'),
                  subtitle: const Text('View and manage your data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Data tab (index 3)
                    final insidePageState = InsidePage.of(context);
                    if (insidePageState != null) {
                      insidePageState.setIndex(3);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Help & Support Section
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  'Help & Support',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.amber),
                  title: const Text('Help Center'),
                  subtitle: const Text('Get help and support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help Center - Coming soon'),
                      ),
                    );
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
                  leading: const Icon(
                    Icons.feedback_outlined,
                    color: Colors.pink,
                  ),
                  title: const Text('Send Feedback'),
                  subtitle: const Text('Share your thoughts with us'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback form - Coming soon'),
                      ),
                    );
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
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.blueGrey,
                  ),
                  title: const Text('About'),
                  subtitle: const Text('App version and information'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About'),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('App Name: Flutter Dashboard'),
                            SizedBox(height: 8),
                            Text('Version: 1.0.0'),
                            SizedBox(height: 8),
                            Text('Developed by: Your Team'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom padding for better scrolling experience
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
