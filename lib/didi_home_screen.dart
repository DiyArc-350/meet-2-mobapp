import 'package:flutter/material.dart';
import 'package:flutter_application_1/didi_form_screen.dart';
import 'package:flutter_application_1/didi_service.dart';

class DidiHomeScreen extends StatefulWidget {
  const DidiHomeScreen({super.key});

  @override
  State<DidiHomeScreen> createState() => _DidiHomeScreenState();
}

class _DidiHomeScreenState extends State<DidiHomeScreen> {
  final _didiService = DidiService();
  late Future<List<Map<String, dynamic>>> _questionsData;
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
      _questionsData = _didiService.getData();
    });
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    if (_searchQuery.isEmpty) return data;

    return data.where((question) {
      final questionText =
          question['question_didi']?.toString().toLowerCase() ?? '';
      final answer = question['answer_didi']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return questionText.contains(query) || answer.contains(query);
    }).toList();
  }

  void _showDetailDialog(Map<String, dynamic> question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Question Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Question',
                question['question_didi']?.toString() ?? '-',
              ),
              const Divider(),
              _buildDetailRow('Choice 1', question['chouce1_didi'] ?? '-'),
              const Divider(),
              _buildDetailRow('Choice 2', question['chouce2_didi'] ?? '-'),
              const Divider(),
              _buildDetailRow('Choice 3', question['chouce3_didi'] ?? '-'),
              const Divider(),
              _buildDetailRow('Choice 4', question['chouce4_didi'] ?? '-'),
              const Divider(),
              _buildDetailRow('Answer', question['answer_didi'] ?? '-'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DidiFormScreen(existingData: question),
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
            width: 100,
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
        title: const Text('Quiz Questions'),
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
                hintText: 'Search questions or answers...',
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
              future: _questionsData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No questions available.'));
                }

                final filteredList = _filterData(snapshot.data!);

                if (filteredList.isEmpty) {
                  return const Center(child: Text('No search results.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final question = filteredList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        onTap: () => _showDetailDialog(question),
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            'Q${question['question_id_didi']?.toString() ?? '?'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          question['question_didi'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Answer: ${question['answer_didi'] ?? '-'}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                                    builder: (context) =>
                                        DidiFormScreen(existingData: question),
                                  ),
                                );
                                _refreshData();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm'),
                                    content: const Text(
                                      'Are you sure you want to delete this question?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await _didiService.deleteData(
                                    question['question_id_didi'].toString(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DidiFormScreen()),
          );
          _refreshData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
