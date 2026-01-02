/// Service for managing crop photos - capture, storage, and deletion
library;

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for handling photo capture and file management
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Capture a photo from the camera
  Future<String?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo == null) return null;

      return await _savePhotoToAppDirectory(photo);
    } catch (e) {
      return null;
    }
  }

  /// Pick a photo from gallery
  Future<String?> pickPhotoFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo == null) return null;

      return await _savePhotoToAppDirectory(photo);
    } catch (e) {
      return null;
    }
  }

  /// Save photo to app's permanent storage directory
  Future<String> _savePhotoToAppDirectory(XFile photo) async {
    // Get the app's document directory
    final Directory appDir = await getApplicationDocumentsDirectory();

    // Create a photos subdirectory if it doesn't exist
    final Directory photosDir = Directory(path.join(appDir.path, 'crop_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    // Generate unique filename with timestamp
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = path.extension(photo.path);
    final String fileName = 'crop_$timestamp$extension';
    final String savedPath = path.join(photosDir.path, fileName);

    // Copy the file to permanent storage
    final File sourceFile = File(photo.path);
    await sourceFile.copy(savedPath);

    return savedPath;
  }

  /// Delete a photo file from storage
  Future<bool> deletePhoto(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if a photo file exists
  Future<bool> photoExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get the size of a photo file in bytes
  Future<int?> getPhotoSize(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete all orphaned photos (photos not in database)
  Future<int> cleanupOrphanedPhotos(Set<String> validPaths) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory photosDir = Directory(path.join(appDir.path, 'crop_photos'));

      if (!await photosDir.exists()) {
        return 0;
      }

      int deletedCount = 0;
      final List<FileSystemEntity> files = await photosDir.list().toList();

      for (final file in files) {
        if (file is File) {
          final String filePath = file.path;
          if (!validPaths.contains(filePath)) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  /// Get total storage used by photos in MB
  Future<double> getTotalStorageUsed() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory photosDir = Directory(path.join(appDir.path, 'crop_photos'));

      if (!await photosDir.exists()) {
        return 0.0;
      }

      int totalBytes = 0;
      final List<FileSystemEntity> files = await photosDir.list().toList();

      for (final file in files) {
        if (file is File) {
          totalBytes += await file.length();
        }
      }

      return totalBytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      return 0.0;
    }
  }
}
