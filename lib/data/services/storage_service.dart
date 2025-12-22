import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadProfilePic(String userId, File file) async {
    try {
      final fileExt = p.extension(file.path);
      final fileName = 'profile_$userId$fileExt';
      final filePath = 'avatars/$fileName';

      await _supabase.storage.from('medinest').upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl =
          _supabase.storage.from('medinest').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading profile pic: $e');
      return null;
    }
  }

  Future<String?> uploadPrescription(String userId, File file) async {
    try {
      final fileExt = p.extension(file.path);
      final fileName =
          'prescription_${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'prescriptions/$fileName';

      await _supabase.storage.from('medinest').upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl =
          _supabase.storage.from('medinest').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading prescription: $e');
      return null;
    }
  }
}
