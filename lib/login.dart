import 'package:flutter/material.dart';
import 'dashboard.dart'; // <-- replace with your real page
import 'register_page.dart'; // <-- replace with your real page
import 'reset_password.dart'; // <-- replace with your real page

void main() => runApp(Login());

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  Widget _circle(double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('lib/assets/dhy.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 900;

    // Responsive padding
    final horizontalPadding = isSmallScreen
        ? 24.0
        : (isMediumScreen ? 60.0 : 120.0);

    // Responsive circle sizes
    final circle1 = isSmallScreen ? 40.0 : (isMediumScreen ? 50.0 : 60.0);
    final circle2 = isSmallScreen ? 30.0 : (isMediumScreen ? 40.0 : 50.0);
    final circle3 = isSmallScreen ? 20.0 : (isMediumScreen ? 30.0 : 40.0);
    final circle4 = isSmallScreen ? 90.0 : (isMediumScreen ? 110.0 : 130.0);

    // Responsive font sizes
    final titleSize = isSmallScreen ? 22.0 : (isMediumScreen ? 26.0 : 30.0);
    final subtitleSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 24.0);
    final emailSize = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
    final labelSize = isSmallScreen ? 20.0 : (isMediumScreen ? 22.0 : 24.0);
    final buttonTextSize = isSmallScreen
        ? 20.0
        : (isMediumScreen ? 22.0 : 24.0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(
            0xFFB9F6CA,
          ), // light-green from the screenshot
          centerTitle: true,
          title: Text(
            'Login Page',
            style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
          ),
        ),
        backgroundColor: const Color(0xFFFFF0F5), // very light pink background
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  SizedBox(height: isSmallScreen ? 40 : 60),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circle(circle1),
                      SizedBox(width: isSmallScreen ? 10 : 15),
                      _circle(circle2),
                      SizedBox(width: isSmallScreen ? 10 : 15),
                      _circle(circle3),
                      SizedBox(width: isSmallScreen ? 10 : 15),
                      _circle(circle4),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 10 : 20),

                  Text(
                    'Dhiya Isnavisa',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text('1101224329', style: TextStyle(fontSize: subtitleSize)),
                  Text(
                    'dhiyaisnavisa@gmail.com',
                    style: TextStyle(
                      fontSize: emailSize,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                    'Hasil Kalkulator:',
                    style: TextStyle(
                      fontSize: emailSize,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 40 : 60),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Username',
                      style: TextStyle(fontSize: labelSize),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  TextField(
                    controller: _usernameCtrl,
                    style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFB9F6CA), // light-green
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your username',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 16 : 20,
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(fontSize: labelSize),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF90CAF9), // light-blue
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your password',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 16 : 20,
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 30 : 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 16 : 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // TODO: real authentication logic here
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InsidePage()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: buttonTextSize,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 30 : 40),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isSmallScreen ? 0 : 20,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ResetPage()),
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
