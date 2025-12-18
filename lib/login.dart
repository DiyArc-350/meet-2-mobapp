import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/register_page.dart';
import 'package:flutter_application_1/reset_password.dart';
import 'package:flutter_application_1/services/biometric_auth_service.dart';
import 'package:flutter_application_1/user_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final supabase = Supabase.instance.client;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = await _biometricAuthService
        .isBiometricAvailable();
    if (canCheckBiometrics) {
      // Optionally show a message or enable biometric button state
      print("Biometrics available");
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = await _biometricAuthService.authenticate();
    if (authenticated) {
      setState(() => _isLoading = true);
      try {
        final email = await _storage.read(key: 'email');
        final password = await _storage.read(key: 'password');

        if (email != null && password != null) {
          final response = await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (response.session != null) {
            try {
              final userData = await supabase
                  .from('users')
                  .select('level')
                  .eq('id', response.user!.id)
                  .single();
              UserSession.level = userData['level'] as int?;
            } catch (e) {
              UserSession.level = 1;
            }

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => InsidePage()),
              );
            }
          } else {
            _showMessage('Biometric login failed. Please login with password.');
          }
        } else {
          _showMessage(
            'Please login with password first to enable biometrics.',
          );
        }
      } catch (e) {
        _showMessage('Biometric login error: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _login() async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        // Fetch user level
        try {
          final userData = await supabase
              .from('users')
              .select('level')
              .eq('id', response.user!.id)
              .single();
          UserSession.level = userData['level'] as int?;
        } catch (e) {
          // Default to Level 1 if error or user not found
          print('Error fetching user level: $e');
          UserSession.level = 1;
        }

        // Simpan creds untuk biometric next time
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'password', value: password);

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
        title: const Text("Login Page - 1101224329"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              const SizedBox(height: 80),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text("Email", style: TextStyle(fontSize: 20)),
              ),
              TextField(
                autofillHints: const [AutofillHints.email],
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
                autofillHints: const [AutofillHints.password],
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
              IconButton(
                icon: const Icon(Icons.fingerprint, size: 50),
                onPressed: _authenticate,
                tooltip: 'Login with Biometrics',
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
      ),
    );
  }
}
