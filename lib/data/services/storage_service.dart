import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<void> _ensureBucketExists() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final exists = buckets.any((b) => b.id == 'kayaone');
      if (!exists) {
        await _supabase.storage
            .createBucket('kayaone', const BucketOptions(public: true));
      }
    } catch (_) {
      // Ignore if it fails (e.g. already exists or permissions issue)
      // If permission is denied, the subsequent upload will fail anyway, which is caught.
    }
  }

  Future<String?> uploadProfilePic(String userId, File file) async {
    try {
      await _ensureBucketExists();
      final fileExt = p.extension(file.path);
      final fileName = 'profile_$userId$fileExt';
      final filePath = 'avatars/$fileName';

      await _supabase.storage.from('kayaone').upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl =
          _supabase.storage.from('kayaone').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading profile pic: $e');
      if (e is StorageException) {
        print('Message: ${e.message}');
        print('Error: ${e.error}');
        print('StatusCode: ${e.statusCode}');
      }
      return null;
    }
  }

  Future<String?> uploadPrescription(String userId, File file) async {
    try {
      await _ensureBucketExists();
      final fileExt = p.extension(file.path);
      final fileName =
          'prescription_${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'prescriptions/$fileName';

      await _supabase.storage.from('kayaone').upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl =
          _supabase.storage.from('kayaone').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading prescription: $e');
      if (e is StorageException) {
        print('Message: ${e.message}');
        print('Error: ${e.error}');
        print('StatusCode: ${e.statusCode}');
      }
      return null;
    }
  }
}
