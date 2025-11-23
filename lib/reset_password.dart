import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ResetPage extends StatefulWidget {
  const ResetPage({super.key});

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _showPasswordFields = false;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Email wajib diisi');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showMessage('Format email tidak valid');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // PERBAIKAN: Gunakan parameter yang benar
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'io.supabase.flutterdemo://reset-callback/', // Sesuaikan dengan redirect URL Anda
      );

      _showMessage('OTP telah dikirim ke email Anda. Silakan cek email Anda.');
      setState(() {
        _otpSent = true;
        _showPasswordFields = true;
      });
    } on AuthException catch (e) {
      _showMessage('Gagal mengirim OTP: ${e.message}');
    } catch (e) {
      _showMessage('Terjadi error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (otp.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Semua field harus diisi');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Password baru dan konfirmasi password tidak cocok');
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('Password minimal 6 karakter');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // PERBAIKAN: Verifikasi OTP dengan email
      final response = await supabase.auth.verifyOTP(
        email: email, // Tambahkan email di sini
        token: otp,
        type: OtpType.recovery,
      );

      if (response.session != null) {
        // Update password user
        await supabase.auth.updateUser(
          UserAttributes(password: newPassword),
        );

        _showMessage(
            'Password berhasil direset! Silakan login dengan password baru.');

        // Kembali ke halaman login
        Navigator.pop(context);
      } else {
        _showMessage('OTP tidak valid atau telah kadaluarsa');
      }
    } on AuthException catch (e) {
      _showMessage('Gagal reset password: ${e.message}');
    } catch (e) {
      _showMessage('Terjadi error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Masukkan email Anda untuk menerima kode OTP reset password.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              enabled: !_otpSent,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // OTP Field (muncul setelah email dikirim)
            if (_otpSent) ...[
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'Kode OTP',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'Masukkan kode OTP dari email',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],

            // Password Fields (muncul setelah OTP dikirim)
            if (_showPasswordFields) ...[
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
            ],

            // Send OTP Button (hanya muncul jika OTP belum dikirim)
            if (!_otpSent)
              FilledButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: Text(_isLoading ? 'Mengirim OTP...' : 'Kirim OTP'),
              ),

            // Reset Password Button (muncul setelah OTP dikirim)
            if (_otpSent)
              FilledButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: Text(_isLoading ? 'Memproses...' : 'Reset Password'),
              ),

            // Back to Login
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    );
  }
}
  