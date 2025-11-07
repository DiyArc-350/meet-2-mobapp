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
          image: AssetImage('lib/assets/dhy.PNG'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(
            0xFFB9F6CA,
          ), // light-green from the screenshot
          centerTitle: true,
          title: const Text('Login Page'),
        ),
        backgroundColor: const Color(0xFFFFF0F5), // very light pink background
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _circle(40),
                  const SizedBox(width: 10),
                  _circle(30),
                  const SizedBox(width: 10),
                  _circle(20),
                  const SizedBox(width: 10),
                  _circle(90),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                'Dhiya Isnavisa',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text('1101224329', style: TextStyle(fontSize: 18)),
              const Text(
                'dhiyaisnavisa@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hasil Kalkulator:',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),

              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Username', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFB9F6CA), // light-green
                  border: const OutlineInputBorder(),
                  hintText: 'Enter your username',
                ),
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Password', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF90CAF9), // light-blue
                  border: const OutlineInputBorder(),
                  hintText: 'Enter your password',
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 20, color: Colors.purple),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text('Register'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ResetPage()),
                    ),
                    child: const Text('Reset Password'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
