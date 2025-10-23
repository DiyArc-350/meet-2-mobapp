import 'package:flutter/material.dart';
import 'package:flutter_application_1/form_screen.dart';
import 'package:flutter_application_1/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabaseService =
      SupabaseService(); // Fixed: Changed from 'get' to 'final'
  late Future<List<Map<String, dynamic>>> _mahasiswaData;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _mahasiswaData = _supabaseService.getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mahasiswa'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mahasiswaData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data mahasiswa.'));
          }

          final mahasiswaList = snapshot.data!;
          return ListView.builder(
            itemCount: mahasiswaList.length,
            itemBuilder: (context, index) {
              final mhs = mahasiswaList[index];
              final bidang = mhs['bidang']?.toString() ?? '-';
              return ListTile(
                title: Text(mhs['nama'] ?? '-'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'nim: ${mhs['nim'] ?? '-'} - Kelas: ${mhs['kelas'] ?? '-'}',
                    ),
                    Text('Nilai: ${mhs['nilai'] ?? 0}'),
                    Text('Bidang: $bidang'),
                    Text('Gender: ${mhs['gender'] ?? '-'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormScreen(existingData: mhs),
                          ),
                        );
                        _refreshData();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _supabaseService.deleteData(mhs['id'].toString());
                        _refreshData();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormScreen(),
            ), // Fixed: Added 'const'
          );
          _refreshData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
