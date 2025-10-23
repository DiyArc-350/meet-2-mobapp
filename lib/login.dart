import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'register_page.dart';
import 'reset_password.dart';

void main() {
  runApp(Login());
}

class Login extends StatelessWidget {
  Login({super.key});
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: Text("Login Page"),
        ),
        body: Column(
          children: [
            SizedBox(height: 100),
            Container(
              alignment: Alignment.centerLeft,
              child: Text("Username", style: TextStyle(fontSize: 20)),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your username',
              ),
              controller: usernameController,
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              child: Text("Password", style: TextStyle(fontSize: 20)),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your password',
              ),
              controller: passwordController,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InsidePage()),
                  );
                },
                child: Text("Login", style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () => [
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  ),
                ], child: Text("Register")),
                TextButton(onPressed: () => [
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPage()),
                  ),
                ], child: Text("Reset Password")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
