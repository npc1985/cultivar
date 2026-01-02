/// Photo gallery widget for displaying and managing crop photos
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garden.dart';
import '../providers/garden_provider.dart';
import '../services/photo_service.dart';

/// Photo gallery for a specific crop with add/delete capabilities
class CropPhotoGallery extends ConsumerWidget {
  const CropPhotoGallery({
    super.key,
    required this.cropId,
    this.onPhotoTap,
  });

  final String cropId;
  final void Function(CropPhoto)? onPhotoTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosForCropProvider(cropId));
    final photoNotifier = ref.read(photosProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photos (${photos.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: () => _showAddPhotoDialog(context, ref, cropId),
                  tooltip: 'Add Photo',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (photos.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No photos yet',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return _PhotoThumbnail(
                      photo: photo,
                      onTap: () {
                        if (onPhotoTap != null) {
                          onPhotoTap!(photo);
                        } else {
                          _showPhotoDetail(context, ref, photo);
                        }
                      },
                      onDelete: () => _confirmDelete(context, ref, photo),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddPhotoDialog(
    BuildContext context,
    WidgetRef ref,
    String cropId,
  ) async {
    final photoService = PhotoService();

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    // Show loading indicator
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    String? filePath;
    if (choice == 'camera') {
      filePath = await photoService.capturePhoto();
    } else if (choice == 'gallery') {
      filePath = await photoService.pickPhotoFromGallery();
    }

    // Dismiss loading indicator
    if (context.mounted) {
      Navigator.pop(context);
    }

    if (filePath != null && context.mounted) {
      // Show stage selection dialog
      final stage = await _showStageSelectionDialog(context);

      if (stage != null) {
        await ref.read(photosProvider.notifier).quickAddPhoto(
              cropId: cropId,
              filePath: filePath,
              stage: stage,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo added successfully')),
          );
        }
      }
    }
  }

  Future<PhotoStage?> _showStageSelectionDialog(BuildContext context) async {
    return showDialog<PhotoStage>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Growth Stage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PhotoStage.values.map((stage) {
            return ListTile(
              leading: Text(stage.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(stage.displayName),
              onTap: () => Navigator.pop(context, stage),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CropPhoto photo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete file from storage
      final photoService = PhotoService();
      await photoService.deletePhoto(photo.filePath);

      // Delete from database
      await ref.read(photosProvider.notifier).deletePhoto(photo.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo deleted')),
        );
      }
    }
  }

  void _showPhotoDetail(BuildContext context, WidgetRef ref, CropPhoto photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PhotoDetailScreen(photo: photo),
      ),
    );
  }
}

/// Photo thumbnail widget
class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({
    required this.photo,
    required this.onTap,
    required this.onDelete,
  });

  final CropPhoto photo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 120,
                height: 120,
                child: File(photo.filePath).existsSync()
                    ? Image.file(
                        File(photo.filePath),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.broken_image,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
              ),
            ),
          ),
          if (photo.stage != null)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  photo.stage!.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen photo detail view
class _PhotoDetailScreen extends StatelessWidget {
  const _PhotoDetailScreen({required this.photo});

  final CropPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(photo.stage?.displayName ?? 'Photo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                child: File(photo.filePath).existsSync()
                    ? Image.file(File(photo.filePath))
                    : const Icon(Icons.broken_image, size: 100),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photo.stage != null)
                  Text(
                    '${photo.stage!.emoji} ${photo.stage!.displayName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 8),
                Text(
                  'Captured: ${_formatDate(photo.capturedAt)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (photo.caption != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    photo.caption!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
