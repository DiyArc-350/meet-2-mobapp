import 'package:flutter/material.dart';
import 'package:flutter_application_1/form_screen.dart';
import 'package:flutter_application_1/supabase_service.dart';
import 'package:flutter_application_1/user_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _mahasiswaData;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _mahasiswaData = _supabaseService.getData();
    });
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    if (_searchQuery.isEmpty) return data;

    return data.where((mhs) {
      final nama = mhs['nama']?.toString().toLowerCase() ?? '';
      final nim = mhs['nim']?.toString().toLowerCase() ?? '';
      final kelas = mhs['kelas']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return nama.contains(query) ||
          nim.contains(query) ||
          kelas.contains(query);
    }).toList();
  }

  void _showDetailDialog(Map<String, dynamic> mhs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mhs['nama'] ?? '-'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('NIM', mhs['nim']?.toString() ?? '-'),
              const Divider(),
              _buildDetailRow('Kelas', mhs['kelas'] ?? '-'),
              const Divider(),
              _buildDetailRow('Nilai', mhs['nilai']?.toString() ?? '0'),
              const Divider(),
              _buildDetailRow('Bidang', mhs['bidang']?.toString() ?? '-'),
              const Divider(),
              _buildDetailRow('Gender', mhs['gender'] ?? '-'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if ((UserSession.level ?? 1) >= 2)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormScreen(existingData: mhs),
                  ),
                ).then((_) => _refreshData());
              },
              child: const Text('Edit'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama, NIM, atau kelas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _mahasiswaData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data mahasiswa.'));
                }

                final filteredList = _filterData(snapshot.data!);

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada hasil pencarian.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final mhs = filteredList[index];
                    final bidang = mhs['bidang']?.toString() ?? '-';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        onTap: () => _showDetailDialog(mhs),
                        leading: CircleAvatar(
                          child: Text(
                            mhs['nama']
                                    ?.toString()
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                '?',
                          ),
                        ),
                        title: Text(
                          mhs['nama'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'NIM: ${mhs['nim'] ?? '-'} - Kelas: ${mhs['kelas'] ?? '-'}',
                            ),
                            Text(
                              'Nilai: ${mhs['nilai'] ?? 0} • ${mhs['gender'] ?? '-'}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if ((UserSession.level ?? 1) >= 2)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FormScreen(existingData: mhs),
                                    ),
                                  );
                                  _refreshData();
                                },
                              ),
                            if ((UserSession.level ?? 1) >= 3)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Konfirmasi'),
                                      content: const Text(
                                        'Yakin ingin menghapus data ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await _supabaseService.deleteData(
                                      mhs['id'].toString(),
                                    );
                                    _refreshData();
                                  }
                                },
                              ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: (UserSession.level ?? 1) >= 2
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormScreen()),
                );
                _refreshData();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
