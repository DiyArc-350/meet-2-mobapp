import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class MoviesSupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'movies';
  final String _bucketName = 'thumbnail';

  // Get all movies
  Future<List<Map<String, dynamic>>> getData() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('id', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting data: $e');
      rethrow;
    }
  }

  // Upload image to Supabase Storage (Mobile)
  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      final String filePath = 'public/$fileName';

      await _client.storage.from(_bucketName).upload(filePath, imageFile);

      // Get public URL
      final String publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Upload image to Supabase Storage (Web)
  Future<String?> uploadImageWeb(XFile imageFile, String fileName) async {
    try {
      final String filePath = 'public/$fileName';
      final bytes = await imageFile.readAsBytes();

      await _client.storage.from(_bucketName).uploadBinary(filePath, bytes);

      // Get public URL
      final String publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the path after 'thumbnail'
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(_bucketName).remove([filePath]);
      }
    } catch (e) {
      print('Error deleting image: $e');
      // Don't rethrow - image deletion failure shouldn't block other operations
    }
  }

  // Insert new movie
  Future<void> insertData(Map<String, dynamic> data) async {
    try {
      await _client.from(_tableName).insert(data);
    } catch (e) {
      print('Error inserting data: $e');
      rethrow;
    }
  }

  // Update existing movie
  Future<void> updateData(String id, Map<String, dynamic> data) async {
    try {
      await _client.from(_tableName).update(data).eq('id', id);
    } catch (e) {
      print('Error updating data: $e');
      rethrow;
    }
  }

  // Delete movie
  Future<void> deleteData(String id, String? imageUrl) async {
    try {
      // Delete image first if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteImage(imageUrl);
      }

      // Then delete the movie record
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      print('Error deleting data: $e');
      rethrow;
    }
  }
}
