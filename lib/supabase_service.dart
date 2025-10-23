import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName =
      'students'; // Changed to match your actual table name

  // Get all data
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting data: $e');
      rethrow;
    }
  }

  // Insert new data
  Future<void> insertData(Map<String, dynamic> data) async {
    try {
      await _client.from(_tableName).insert(data);
    } catch (e) {
      print('Error inserting data: $e');
      rethrow;
    }
  }

  // Update existing data
  Future<void> updateData(String id, Map<String, dynamic> data) async {
    try {
      await _client.from(_tableName).update(data).eq('id', id);
    } catch (e) {
      print('Error updating data: $e');
      rethrow;
    }
  }

  // Delete data
  Future<void> deleteData(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      print('Error deleting data: $e');
      rethrow;
    }
  }
}
