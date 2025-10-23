import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorPage());
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListView(
          children: [
            const Center(
              child: Text("FIRST PROJECT", style: TextStyle(fontSize: 30)),
            ),
            Center(child: Text("1101224329")),
            const CircleAvatar(
              backgroundImage: AssetImage('lib/assets/dhy.PNG'),
              radius: 300,
            ),
            SizedBox(height: 20),
            Container(
              color: Colors.cyan[100],
              alignment: Alignment.bottomRight,
              child: Text(_output, style: TextStyle(fontSize: 50)),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                  _buildCalculatorButton("7"),  
                  _buildCalculatorButton("8"), 
                  _buildCalculatorButton("9"), 
                  _buildCalculatorButton("÷", color: Colors.orange, textColor: Colors.white)]
              ),
            Row(
              children: [
                  _buildCalculatorButton("4"),  
                  _buildCalculatorButton("5"), 
                  _buildCalculatorButton("6"), 
                  _buildCalculatorButton("×", color: Colors.orange, textColor: Colors.white)]
              ),
            Row(
              children: [
                  _buildCalculatorButton("1"),  
                  _buildCalculatorButton("2"), 
                  _buildCalculatorButton("3"), 
                  _buildCalculatorButton("-", color: Colors.orange, textColor: Colors.white)]
              ), 
            Row(
              children: [
                  _buildCalculatorButton("C", color: Colors.red, textColor: Colors.white),  
                  _buildCalculatorButton("0"), 
                  _buildCalculatorButton("⌫", color: Colors.red, textColor: Colors.white), 
                  _buildCalculatorButton("+", color: Colors.orange, textColor: Colors.white)]
              ),
            Row(
              children: [
                  _buildCalculatorButton(".", color: Colors.blue, textColor: Colors.white),  
                  _buildCalculatorButton("=", color: Colors.green, textColor: Colors.white), 
              ]
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorButton(String buttonText,
      {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[200],
            foregroundColor: textColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(80),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  String _output = "0";
  String _currentInput = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operator = "";
  bool _shouldResetInput = false;

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        // Clear everything
        _output = "0";
        _currentInput = "";
        _num1 = 0;
        _num2 = 0;
        _operator = "";
        _shouldResetInput = false;
      } else if (buttonText == "⌫") {
        // Backspace
        if (_currentInput.isNotEmpty) {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
          if (_currentInput.isEmpty) {
            _currentInput = "0";
          }
          _output = _currentInput;
        }
      } else if (buttonText == ".") {
        // Decimal point
        if (!_currentInput.contains(".")) {
          _currentInput += _currentInput.isEmpty ? "0." : ".";
          _output = _currentInput;
        }
      } else if (buttonText == "=") {
        // Perform calculation
        if (_operator.isNotEmpty && _currentInput.isNotEmpty) {
          _num2 = double.parse(_currentInput);
          switch (_operator) {
            case "+":
              _output = (_num1 + _num2).toString();
              break;
            case "-":
              _output = (_num1 - _num2).toString();
              break;
            case "×":
              _output = (_num1 * _num2).toString();
              break;
            case "÷":
              _output = _num2 != 0 ? (_num1 / _num2).toString() : "Error";
              break;
          }

          // Remove trailing .0 if present
          if (_output.endsWith(".0")) {
            _output = _output.substring(0, _output.length - 2);
          }

          _currentInput = _output;
          _operator = "";
          _shouldResetInput = true;
        }
      } else if (["+", "-", "×", "÷"].contains(buttonText)) {
        // Operator pressed
        if (_currentInput.isNotEmpty) {
          _num1 = double.parse(_currentInput);
          _operator = buttonText;
          _output = _num1.toString() + " " + _operator;
          _shouldResetInput = true;
        }
      } else {
        // Number pressed
        if (_shouldResetInput) {
          _currentInput = "";
          _shouldResetInput = false;
        }

        if (_currentInput == "0") {
          _currentInput = buttonText;
        } else {
          _currentInput += buttonText;
        }
        _output = _currentInput;
      }
    });
  }
}
