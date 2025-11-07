import 'package:supabase_flutter/supabase_flutter.dart';

class DidiService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'didi29';

  // Get all questions
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('question_id_didi', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting data: $e');
      rethrow;
    }
  }

  // Insert new question
  Future<void> insertData(Map<String, dynamic> data) async {
    try {
      await _client.from(_tableName).insert(data);
    } catch (e) {
      print('Error inserting data: $e');
      rethrow;
    }
  }

  // Update existing question
  Future<void> updateData(String id, Map<String, dynamic> data) async {
    try {
      await _client.from(_tableName).update(data).eq('question_id_didi', id);
    } catch (e) {
      print('Error updating data: $e');
      rethrow;
    }
  }

  // Delete question
  Future<void> deleteData(String id) async {
    try {
      await _client.from(_tableName).delete().eq('question_id_didi', id);
    } catch (e) {
      print('Error deleting data: $e');
      rethrow;
    }
  }
}
