import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation controller = the metronome
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // loop back and forth

    // Tween = range of values (0.8x to 1.2x size)
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose(); // don’t leak memory like a rookie
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text("FIRST PROJECT", style: TextStyle(fontSize: 30)),
        ),
        const SizedBox(height: 20),
        const Text(
          "1101224329 - Dhiya Isnavisa",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),

        // Here’s the animated CircleAvatar
        ScaleTransition(
          scale: _animation,
          child: const CircleAvatar(
            backgroundImage: AssetImage('lib/assets/dhy.png'),
            radius: 60,
          ),
        ),
      ],
    );
  }
}
