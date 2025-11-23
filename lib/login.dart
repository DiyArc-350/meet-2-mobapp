import 'package:flutter/material.dart';
import 'package:flutter_application_1/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/register_page.dart';
import 'package:flutter_application_1/reset_password.dart';

final supabase = Supabase.instance.client;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // signInWithPassword adalah cara login email & password di Supabase
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        // Login berhasil, arahkan ke Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InsidePage()),
        );
      } else {
        _showMessage('Email atau password salah');
      }
    } on AuthException catch (e) {
      _showMessage('Gagal login: ${e.message}');
    } catch (e) {
      _showMessage('Terjadi error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: const Text("Login Page/08780030"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text("Email", style: TextStyle(fontSize: 20)),
            ),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
              ),
              controller: usernameController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text("Password", style: TextStyle(fontSize: 20)),
            ),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your password',
              ),
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: Text(
                _isLoading ? "Loading..." : "Login",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text("Register"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResetPage(),
                      ),
                    );
                  },
                  child: const Text("Reset Password"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
