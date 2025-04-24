import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'dart:async';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Upload an image and return the download URL
  Future<String> uploadImage(File imageFile, String chatRoomId) async {
    // Verify file exists before attempting upload
    if (!await imageFile.exists()) {
      throw FileSystemException(
          'File does not exist or cannot be accessed', imageFile.path);
    }

    // Check file size - reject if over 10MB to prevent long uploads
    final fileSize = await imageFile.length();
    if (fileSize > 10 * 1024 * 1024) {
      throw Exception(
          'Image too large. Please select an image smaller than 10MB.');
    }

    try {
      // Generate a simple filename with UUID to prevent collisions
      // Avoid complex paths that might cause 404 errors
      String fileName = 'image_${_uuid.v4()}${path.extension(imageFile.path)}';

      // Use the root reference directly without nested folders
      // This is critical for fixing the "object not found" error
      Reference ref = _storage.ref().child(fileName);

      // Set metadata to include content type for proper display in browsers
      String extension = path.extension(imageFile.path).replaceAll('.', '');
      if (extension.isEmpty) {
        extension = 'jpeg'; // Default to jpeg if no extension
      }

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {
          'uploaded_at': DateTime.now().toString(),
          'chat_room_id': chatRoomId,
          'file_size': fileSize.toString(),
        },
      );

      // Start upload task with metadata
      UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // Listen for state changes, errors, and completion events
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      }, onError: (e) {
        print('Upload task error: $e');
      });

      // Get the download URL once the upload is complete
      TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Upload timed out after 60 seconds');
        },
      );
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print(
          'Upload completed successfully. Size: ${(fileSize / 1024).round()}KB');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: ${e.code} - ${e.message}');
      if (e.code == 'unauthorized') {
        throw Exception(
            'Storage permission denied. Please check your app permissions.');
      } else if (e.code == 'canceled') {
        throw Exception('Upload was cancelled.');
      } else if (e.code == 'storage/quota-exceeded') {
        throw Exception('Storage quota exceeded. Please contact support.');
      } else if (e.code == 'object-not-found') {
        // This specific error happens when the storage path doesn't exist
        throw Exception(
            'Storage path error. Try simplifying the path structure.');
      } else {
        throw Exception('Failed to upload image: ${e.message}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image. Please try again.');
    }
  }

  // Delete an image from storage to clean up unused files
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Create a reference from the URL
      Reference ref = _storage.refFromURL(imageUrl);

      // Delete the file
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Silently fail as this shouldn't block the user experience
    }
  }
}
