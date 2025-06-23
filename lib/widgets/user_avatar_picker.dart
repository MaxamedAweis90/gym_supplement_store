import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gym_supplement_store/service/supabase_config.dart';

class UserAvatarPicker extends StatefulWidget {
  final String? initialImageUrl;
  final String userId;
  final Function(String? imageUrl) onImageChanged;
  final double size;
  final bool showEditButton;

  const UserAvatarPicker({
    super.key,
    this.initialImageUrl,
    required this.userId,
    required this.onImageChanged,
    this.size = 100,
    this.showEditButton = true,
  });

  @override
  State<UserAvatarPicker> createState() => _UserAvatarPickerState();
}

class _UserAvatarPickerState extends State<UserAvatarPicker> {
  String? _imageUrl;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(UserAvatarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the local image URL when the prop changes
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      setState(() {
        _imageUrl = widget.initialImageUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                await _handlePick(SupabaseConfig.pickImageFromGallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.of(context).pop();
                await _handlePick(SupabaseConfig.takePhotoWithCamera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePick(Future<File?> Function() pickFn) async {
    setState(() => _isUploading = true);

    try {
      final file = await pickFn();
      if (file != null) {
        final url = await SupabaseConfig.uploadUserAvatar(
          imageFile: file,
          userId: widget.userId,
        );

        if (url != null) {
          // Delete old image if it exists and is different
          if (_imageUrl != null && _imageUrl != url) {
            await SupabaseConfig.deleteUserAvatar(imageUrl: _imageUrl!);
          }

          setState(() {
            _imageFile = file;
            _imageUrl = url;
          });

          widget.onImageChanged(url);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _removeImage() async {
    try {
      // Delete old image if it exists
      if (_imageUrl != null) {
        await SupabaseConfig.deleteUserAvatar(imageUrl: _imageUrl!);
      }

      setState(() {
        _imageFile = null;
        _imageUrl = null;
      });

      widget.onImageChanged(null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image removed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        children: [
          // Perfect Circular Avatar with Enhanced Design
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 3,
                  ),
                ),
                child: _isUploading
                    ? Container(
                        color: theme.colorScheme.surface,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : _imageUrl != null
                    ? Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        width: widget.size,
                        height: widget.size,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: theme.colorScheme.surface,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: theme.colorScheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(theme);
                        },
                      )
                    : _buildDefaultAvatar(theme),
              ),
            ),
          ),

          // Enhanced Edit Button
          if (widget.showEditButton)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Icon(
                        _imageUrl != null
                            ? Icons.edit_rounded
                            : Icons.add_a_photo_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Enhanced Remove Button
          if (_imageUrl != null && widget.showEditButton)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: _isUploading ? null : _removeImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onError,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: widget.size * 0.5,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
      ),
    );
  }
}
