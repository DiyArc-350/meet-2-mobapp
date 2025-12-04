import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:flutter_application_1/user_session.dart';

class StorageList extends StatefulWidget {
  const StorageList({super.key});

  @override
  State<StorageList> createState() => _StorageListState();
}

class _StorageListState extends State<StorageList> {
  final supabase = Supabase.instance.client;
  List<FileObject> files = [];
  String searchText = '';
  Set<String> selectedFiles = {};
  String sortMethod = 'Abjad (A-Z)';
  bool isLoading = false;

  final List<String> sortOptions = [
    'Abjad (A-Z)',
    'Abjad (Z-A)',
    'Waktu created (terbaru)',
    'Waktu created (terlama)',
    'Ukuran (terbesar)',
    'Ukuran (terkecil)',
    'Jenis file (A-Z)',
    'Jenis file (Z-A)',
  ];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase.storage.from('storage').list();
      if (mounted) {
        setState(() {
          if (searchText.isEmpty) {
            files = response;
          } else {
            files = response
                .where(
                  (file) => file.name.toLowerCase().contains(
                    searchText.toLowerCase(),
                  ),
                )
                .toList();
          }
          _sortFiles();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading files: $e')));
      }
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      await supabase.storage.from('storage').remove([path]);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File deleted successfully')));
      }
      await _loadFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting file: $e')));
      }
    }
  }

  Future<void> _deleteMultipleFiles() async {
    try {
      await supabase.storage.from('storage').remove(selectedFiles.toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedFiles.length} files deleted')),
        );
        setState(() => selectedFiles.clear());
      }
      await _loadFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting files: $e')));
      }
    }
  }

  Future<void> _renameFile(String oldName, String newName) async {
    try {
      final file = await supabase.storage.from('storage').download(oldName);
      await supabase.storage.from('storage').uploadBinary(newName, file);
      await supabase.storage.from('storage').remove([oldName]);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File renamed successfully')));
      }
      await _loadFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error renaming file: $e')));
      }
    }
  }

  Future<void> _downloadFile(String fileName) async {
    try {
      final publicUrl = supabase.storage.from('storage').getPublicUrl(fileName);
      final uri = Uri.parse(publicUrl);

      bool launched = false;

      // Try external application first
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('External app launch failed: $e');
      }

      // If external app failed, try platform default
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          print('Platform default launch failed: $e');
        }
      }

      // If still failed, try in-app web view
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }

      if (!launched) {
        throw 'Could not launch download';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Opening file...')));
      }
    } catch (e) {
      if (mounted) {
        // Show the URL so user can copy it manually
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Download Link'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Could not open file automatically. Copy this link:'),
                SizedBox(height: 10),
                SelectableText(
                  supabase.storage.from('storage').getPublicUrl(fileName),
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _shareToWhatsApp(String fileUrl) async {
    final encodedUrl = Uri.encodeComponent(fileUrl);
    final whatsAppDirect = "whatsapp://send?text=$encodedUrl";
    final waMeUrl = "https://wa.me/?text=$encodedUrl";

    try {
      if (await canLaunchUrl(Uri.parse(whatsAppDirect))) {
        await launchUrl(
          Uri.parse(whatsAppDirect),
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(Uri.parse(waMeUrl))) {
        await launchUrl(
          Uri.parse(waMeUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'WhatsApp not available';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("WhatsApp tidak tersedia pada perangkat ini."),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final picked = result.files.single;
        await supabase.storage
            .from('storage')
            .uploadBinary(picked.name, picked.bytes!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('File uploaded successfully')));
        }
        await _loadFiles();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
      }
    }
  }

  Future<void> _captureAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        final now = DateTime.now();
        final filename =
            'capture_${DateFormat('yyyyMMdd_HHmmss').format(now)}.jpg';
        final bytes = await image.readAsBytes();
        await supabase.storage.from('storage').uploadBinary(filename, bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Photo uploaded successfully')),
          );
        }
        await _loadFiles();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error capturing photo: $e')));
      }
    }
  }

  void _showFileDetail(FileObject file) {
    final urlResponse = supabase.storage
        .from('storage')
        .getPublicUrl(file.name);
    final imageExt = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final isImage = imageExt.any((e) => file.name.toLowerCase().endsWith(e));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(file.name, style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Size', _formatFileSize(file.metadata?['size'])),
              _buildDetailRow('Created', _formatDate(file.createdAt)),
              SizedBox(height: 10),
              if (isImage) ...[
                Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: Image.network(
                    urlResponse,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 100),
                  ),
                ),
                SizedBox(height: 10),
              ],
              Text('URL:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              SelectableText(urlResponse, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.copy),
            label: Text('Copy URL'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('URL copied to clipboard')),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatFileSize(dynamic size) {
    if (size == null) return 'Unknown';
    int bytes = 0;
    if (size is int) {
      bytes = size;
    } else if (size is String) {
      bytes = int.tryParse(size) ?? 0;
    }

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';

    DateTime? dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      try {
        dateTime = DateTime.parse(date);
      } catch (e) {
        return date; // Return the string as-is if parsing fails
      }
    } else {
      return 'Unknown';
    }

    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bucket: storage'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari file',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (v) async {
                setState(() => searchText = v);
                await _loadFiles();
              },
            ),
          ),

          // Select All & Sort Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                // Select All
                Checkbox(
                  value:
                      selectedFiles.length == files.length && files.isNotEmpty,
                  onChanged: files.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            if (value == true) {
                              selectedFiles.addAll(
                                files.map((file) => file.name),
                              );
                            } else {
                              selectedFiles.clear();
                            }
                          });
                        },
                ),
                Text('Select All (${files.length})'),
                Spacer(),

                // Sort Dropdown
                Text("Sort: ", style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: sortMethod,
                  underline: Container(),
                  items: sortOptions
                      .map(
                        (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
                      )
                      .toList(),
                  onChanged: (newSort) {
                    setState(() {
                      sortMethod = newSort!;
                      _sortFiles();
                    });
                  },
                ),
              ],
            ),
          ),

          // Loading or File List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : files.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No files found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (_, idx) {
                      final file = files[idx];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: selectedFiles.contains(file.name),
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  selectedFiles.add(file.name);
                                } else {
                                  selectedFiles.remove(file.name);
                                }
                              });
                            },
                          ),
                          title: Text(
                            file.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${_formatFileSize(file.metadata?['size'])} • ${_formatDate(file.createdAt)}',
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () => _showFileDetail(file),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (value) async {
                              switch (value) {
                                case 'download':
                                  await _downloadFile(file.name);
                                  break;
                                case 'rename':
                                  _showRenameDialog(file);
                                  break;
                                case 'delete':
                                  _showDeleteDialog(file);
                                  break;
                                case 'share':
                                  final url = supabase.storage
                                      .from('storage')
                                      .getPublicUrl(file.name);
                                  await _shareToWhatsApp(url);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'download',
                                child: Row(
                                  children: [
                                    Icon(Icons.download, size: 20),
                                    SizedBox(width: 12),
                                    Text('Download'),
                                  ],
                                ),
                              ),
                              if ((UserSession.level ?? 1) >= 2)
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 12),
                                      Text('Rename'),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    Icon(Icons.share, size: 20),
                                    SizedBox(width: 12),
                                    Text('Share'),
                                  ],
                                ),
                              ),
                              if ((UserSession.level ?? 1) >= 3)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bulk Delete Button
          if (selectedFiles.length > 1 && (UserSession.level ?? 1) >= 3)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete),
                label: Text('Delete ${selectedFiles.length} files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _showBulkDeleteDialog(),
              ),
            ),
        ],
      ),
      floatingActionButton: (UserSession.level ?? 1) >= 2
          ? FloatingActionButton(
              onPressed: () => _showUploadOptions(),
              backgroundColor: Colors.blue,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.file_present, color: Colors.blue),
              title: Text('Upload File'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadFile();
              },
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('Capture Foto (Kamera)'),
              onTap: () async {
                Navigator.pop(context);
                await _captureAndUploadPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(FileObject file) {
    final nameController = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Rename File'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _renameFile(file.name, nameController.text);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(FileObject file) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteFile(file.name);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Multiple Files'),
        content: Text(
          'Are you sure you want to delete ${selectedFiles.length} files?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMultipleFiles();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sortFiles() {
    switch (sortMethod) {
      case 'Abjad (A-Z)':
        files.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case 'Abjad (Z-A)':
        files.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case 'Waktu created (terbaru)':
        files.sort((a, b) {
          DateTime aDate = DateTime(1900);
          DateTime bDate = DateTime(1900);

          if (a.createdAt != null && a.createdAt is DateTime) {
            aDate = a.createdAt as DateTime;
          }
          if (b.createdAt != null && b.createdAt is DateTime) {
            bDate = b.createdAt as DateTime;
          }

          return bDate.compareTo(aDate);
        });
        break;
      case 'Waktu created (terlama)':
        files.sort((a, b) {
          DateTime aDate = DateTime(1900);
          DateTime bDate = DateTime(1900);

          if (a.createdAt != null && a.createdAt is DateTime) {
            aDate = a.createdAt as DateTime;
          }
          if (b.createdAt != null && b.createdAt is DateTime) {
            bDate = b.createdAt as DateTime;
          }

          return aDate.compareTo(bDate);
        });
        break;
      case 'Ukuran (terbesar)':
        files.sort((a, b) {
          final aSizeObj = a.metadata?['size'];
          final bSizeObj = b.metadata?['size'];
          final aSize = aSizeObj is int ? aSizeObj : 0;
          final bSize = bSizeObj is int ? bSizeObj : 0;
          return bSize.compareTo(aSize);
        });
        break;
      case 'Ukuran (terkecil)':
        files.sort((a, b) {
          final aSizeObj = a.metadata?['size'];
          final bSizeObj = b.metadata?['size'];
          final aSize = aSizeObj is int ? aSizeObj : 0;
          final bSize = bSizeObj is int ? bSizeObj : 0;
          return aSize.compareTo(bSize);
        });
        break;
      case 'Jenis file (A-Z)':
        files.sort((a, b) => _getExt(a.name).compareTo(_getExt(b.name)));
        break;
      case 'Jenis file (Z-A)':
        files.sort((a, b) => _getExt(b.name).compareTo(_getExt(a.name)));
        break;
    }
  }

  String _getExt(String name) {
    final ext = name.split('.').last;
    return ext.toLowerCase();
  }
}
