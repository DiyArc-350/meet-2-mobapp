import 'package:flutter/material.dart';
import 'package:flutter_application_1/supabase_service.dart';

class FormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const FormScreen({super.key, this.existingData});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();

  String _nama = '';
  String _nim = '';
  String _kelas = 'A';
  double _nilai = 0;
  List<String> _bidang = [];
  String? _gender;

  final _kelasOptions = ['A', 'B', 'C'];
  final _bidangOptions = [
    'Machine Learning',
    'Data Sains',
    'Rekayasa Perangkat Lunak',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final data = widget.existingData!;
      _nama = data['nama'] ?? '';
      _nim = (data['nim'] ?? '').toString();
      _kelas = data['kelas'] ?? 'A';
      _nilai = (data['nilai'] ?? 0).toDouble();
      // Fixed: Better handling of BIDANG data
      final bidangData = data['bidang'];
      if (bidangData != null && bidangData.toString().isNotEmpty) {
        _bidang = bidangData
            .toString()
            .split(', ')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      _gender = data['gender'];
    }
  }

  Future<void> _submitForm() async {
    // Fixed: Added validation for gender and bidang
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_gender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan pilih gender')));
      return;
    }

    _formKey.currentState!.save();

    final data = {
      'nama': _nama,
      'nim': int.tryParse(_nim),
      'kelas': _kelas,
      'nilai': _nilai,
      'bidang': _bidang.join(', '),
      'gender': _gender,
    };

    try {
      if (widget.existingData == null) {
        await _supabaseService.insertData(data);
      } else {
        await _supabaseService.updateData(
          widget.existingData!['id'].toString(),
          data,
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildCheckbox(String bidang) => CheckboxListTile(
    title: Text(bidang),
    value: _bidang.contains(bidang),
    onChanged: (val) {
      setState(() {
        if (val == true) {
          _bidang.add(bidang);
        } else {
          _bidang.remove(bidang);
        }
      });
    },
  );

  Widget _buildGenderRadio(String label) => RadioListTile<String>(
    title: Text(label),
    value: label,
    groupValue: _gender,
    onChanged: (val) => setState(() => _gender = val),
  );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingData != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Data' : 'Tambah Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _nama,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => _nama = val!,
              ),
              TextFormField(
                initialValue: _nim,
                decoration: const InputDecoration(labelText: 'NIM'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => _nim = val!,
              ),
              DropdownButtonFormField<String>(
                value: _kelas,
                decoration: const InputDecoration(labelText: 'Kelas'),
                items: _kelasOptions
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (val) => setState(() => _kelas = val!),
              ),
              const SizedBox(height: 16),
              Text('Nilai: ${_nilai.toInt()}'),
              Slider(
                value: _nilai,
                min: 0,
                max: 100,
                divisions: 100,
                label: _nilai.toInt().toString(),
                onChanged: (val) => setState(() => _nilai = val),
              ),
              const SizedBox(height: 16),
              const Text('Bidang yang Disukai'),
              ..._bidangOptions.map(_buildCheckbox),
              const SizedBox(height: 16),
              const Text('Gender'),
              _buildGenderRadio('Pria'),
              _buildGenderRadio('Wanita'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEdit ? 'Perbarui' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
