import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'movies_supabase_service.dart';

class MoviesFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const MoviesFormScreen({super.key, this.existingData});

  @override
  State<MoviesFormScreen> createState() => _MoviesFormScreenState();
}

class _MoviesFormScreenState extends State<MoviesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = MoviesSupabaseService();
  final _imagePicker = ImagePicker();
  final _rilisController = TextEditingController();

  String _judul = '';
  DateTime? _selectedDate;
  String _durasi = '';
  String _genre = '';
  String? _existingImageLink;
  File? _selectedImage;
  XFile? _selectedImageWeb;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final data = widget.existingData!;
      _judul = data['judul'] ?? '';

      // Parse existing date
      if (data['rilis'] != null && data['rilis'].toString().isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(data['rilis']);
          _rilisController.text = _formatDate(_selectedDate!);
        } catch (e) {
          _rilisController.text = data['rilis'];
        }
      }

      _durasi = data['durasi'] ?? '';
      _genre = data['genre'] ?? '';
      _existingImageLink = data['image_link'];
    }
  }

  @override
  void dispose() {
    _rilisController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _rilisController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            _selectedImageWeb = pickedFile;
          } else {
            _selectedImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error memilih gambar: $e')));
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _existingImageLink;

      // Upload new image if selected
      if (_selectedImage != null || _selectedImageWeb != null) {
        // Delete old image if updating
        if (_existingImageLink != null && _existingImageLink!.isNotEmpty) {
          await _supabaseService.deleteImage(_existingImageLink!);
        }

        // Upload new image
        final fileName = 'movie_${DateTime.now().millisecondsSinceEpoch}.jpg';

        if (kIsWeb) {
          imageUrl = await _supabaseService.uploadImageWeb(
            _selectedImageWeb!,
            fileName,
          );
        } else {
          imageUrl = await _supabaseService.uploadImage(
            _selectedImage!,
            fileName,
          );
        }
      }

      final data = {
        'judul': _judul,
        'rilis': _selectedDate != null ? _formatDate(_selectedDate!) : null,
        'durasi': _durasi.isNotEmpty ? _durasi : null,
        'genre': _genre.isNotEmpty ? _genre : null,
        'image_link': imageUrl,
      };

      if (widget.existingData == null) {
        await _supabaseService.insertData(data);
      } else {
        await _supabaseService.updateData(
          widget.existingData!['id'].toString(),
          data,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingData == null
                  ? 'Film berhasil ditambahkan'
                  : 'Film berhasil diperbarui',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImagePreview() {
    // Show selected image (web or mobile)
    if (kIsWeb && _selectedImageWeb != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(_selectedImageWeb!.path, fit: BoxFit.cover),
      );
    } else if (!kIsWeb && _selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_selectedImage!, fit: BoxFit.cover),
      );
    } else if (_existingImageLink != null && _existingImageLink!.isNotEmpty) {
      // Show existing image from database
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _existingImageLink!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.movie, size: 100, color: Colors.grey),
        ),
      );
    } else {
      // Show placeholder
      return const Icon(Icons.movie, size: 100, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingData != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Film' : 'Tambah Film')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Image Preview and Picker
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: _buildImagePreview(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: Text(
                              _selectedImage != null ||
                                      _selectedImageWeb != null ||
                                      _existingImageLink != null
                                  ? 'Ganti Gambar'
                                  : 'Pilih Gambar',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Fields
                    TextFormField(
                      initialValue: _judul,
                      decoration: const InputDecoration(
                        labelText: 'Judul Film',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Wajib diisi' : null,
                      onSaved: (val) => _judul = val!,
                    ),
                    const SizedBox(height: 16),

                    // Date Picker Field
                    TextFormField(
                      controller: _rilisController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Rilis',
                        border: const OutlineInputBorder(),
                        hintText: 'Pilih tanggal',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _durasi,
                      decoration: const InputDecoration(
                        labelText: 'Durasi',
                        border: OutlineInputBorder(),
                        hintText: '120 menit',
                      ),
                      onSaved: (val) => _durasi = val ?? '',
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _genre,
                      decoration: const InputDecoration(
                        labelText: 'Genre',
                        border: OutlineInputBorder(),
                        hintText: 'Action, Drama, Comedy',
                      ),
                      onSaved: (val) => _genre = val ?? '',
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isEdit ? 'Perbarui Film' : 'Simpan Film',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
