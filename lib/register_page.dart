import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // Step 1: Sign up (kirim email OTP)
  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('Semua field harus diisi');
      return;
    }
    if (password != confirm) {
      _showMessage('Password dan konfirmasi tidak sama');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (response.user == null) {
        // signUp berhasil tapi butuh verifikasi email
        _showOtpDialog(email);
      } else {
        // Dalam beberapa kasus user langsung aktif, tapi tetap bisa arahkan ke login
        _showMessage(
          'Registrasi berhasil. Silakan cek email untuk verifikasi.',
        );
        _showOtpDialog(email);
      }
    } on AuthException catch (e) {
      _showMessage('Auth error: ${e.message}');
    } catch (e) {
      _showMessage('Terjadi error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Step 2: Dialog untuk input OTP
  void _showOtpDialog(String email) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSubmitting = false;

        Future<void> submitOtp() async {
          final otp = otpController.text.trim();
          if (otp.isEmpty) {
            _showMessage('OTP tidak boleh kosong');
            return;
          }

          // supaya tombol disable sementara
          if (isSubmitting) return;
          setState(() {}); // supaya rebuild parent jika perlu
          isSubmitting = true;

          try {
            // verify OTP untuk signup
            // Perhatikan: type bisa OtpType.signup atau OtpType.email
            // tergantung versi supabase_flutter; cek dokumentasi/SDK Anda.
            await supabase.auth.verifyOTP(
              email: email,
              token: otp,
              type: OtpType.signup,
            );

            if (mounted) {
              Navigator.of(ctx).pop(); // tutup dialog OTP
              _showMessage('Verifikasi berhasil. Silakan login.');
              Navigator.of(
                context,
              ).pop(); // kembali ke halaman sebelumnya (Login)
            }
          } on AuthException catch (e) {
            _showMessage('OTP salah / kadaluarsa: ${e.message}');
          } catch (e) {
            _showMessage('Terjadi error: $e');
          } finally {
            isSubmitting = false;
          }
        }

        return AlertDialog(
          title: const Text('Masukkan Kode OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kami telah mengirim kode OTP ke email Anda. Silakan cek inbox/spam.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kode OTP',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(onPressed: submitOtp, child: const Text('Submit')),
          ],
        );
      },
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Register New Account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _register,
                child: Text(_isLoading ? 'Loading...' : 'Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
