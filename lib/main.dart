import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xxmhehnoaedkjicjlwfz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4bWhlaG5vYWVka2ppY2psd2Z6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExNjk1NjMsImV4cCI6MjA3Njc0NTU2M30.Dpx1nuM9BgiVJKYeis6t0R-0PGXsVVq4ETm_3_8e9bE',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          return SplashScreen(
            onFinish: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          );
        },
      ),
    );
  }
}
