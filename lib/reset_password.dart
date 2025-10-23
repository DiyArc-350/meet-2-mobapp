import 'package:flutter/material.dart';

class ResetPage extends StatelessWidget {
  const ResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Forgot your password?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your email address and we will send you a link to reset your password.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 24),

            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}