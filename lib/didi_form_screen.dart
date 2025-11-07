
import 'package:flutter/material.dart';
import 'package:flutter_application_1/didi_service.dart';

class DidiFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const DidiFormScreen({super.key, this.existingData});

  @override
  State<DidiFormScreen> createState() => _DidiFormScreenState();
}

class _DidiFormScreenState extends State<DidiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _didiService = DidiService();

  late TextEditingController _questionController;
  late TextEditingController _choice1Controller;
  late TextEditingController _choice2Controller;
  late TextEditingController _choice3Controller;
  late TextEditingController _choice4Controller;
  late TextEditingController _answerController;

  bool _isLoading = false;
  bool get _isEditMode => widget.existingData != null;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.existingData?['question_didi'] ?? '',
    );
    _choice1Controller = TextEditingController(
      text: widget.existingData?['chouce1_didi'] ?? '',
    );
    _choice2Controller = TextEditingController(
      text: widget.existingData?['chouce2_didi'] ?? '',
    );
    _choice3Controller = TextEditingController(
      text: widget.existingData?['chouce3_didi'] ?? '',
    );
    _choice4Controller = TextEditingController(
      text: widget.existingData?['chouce4_didi'] ?? '',
    );
    _answerController = TextEditingController(
      text: widget.existingData?['answer_didi'] ?? '',
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _choice1Controller.dispose();
    _choice2Controller.dispose();
    _choice3Controller.dispose();
    _choice4Controller.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'question_didi': _questionController.text.trim(),
        'chouce1_didi': _choice1Controller.text.trim(),
        'chouce2_didi': _choice2Controller.text.trim(),
        'chouce3_didi': _choice3Controller.text.trim(),
        'chouce4_didi': _choice4Controller.text.trim(),
        'answer_didi': _answerController.text.trim(),
      };

      if (_isEditMode) {
        await _didiService.updateData(
          widget.existingData!['question_id_didi'].toString(),
          data,
        );
      } else {
        await _didiService.insertData(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Question updated successfully!'
                  : 'Question added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Question' : 'Add Question'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.question_answer),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _choice1Controller,
              decoration: const InputDecoration(
                labelText: 'Choice 1',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.looks_one),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter choice 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _choice2Controller,
              decoration: const InputDecoration(
                labelText: 'Choice 2',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.looks_two),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter choice 2';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _choice3Controller,
              decoration: const InputDecoration(
                labelText: 'Choice 3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.looks_3),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter choice 3';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _choice4Controller,
              decoration: const InputDecoration(
                labelText: 'Choice 4',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.looks_4),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter choice 4';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Correct Answer',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.check_circle),
                helperText: 'Enter the correct choice (e.g., Choice 1)',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the correct answer';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditMode ? 'Update Question' : 'Add Question'),
            ),
          ],
        ),
      ),
    );
  }
}