import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class AvatarSelectionBottomSheet extends StatefulWidget {
  final Function(String) onImageSelected;

  const AvatarSelectionBottomSheet({super.key, required this.onImageSelected});

  @override
  State<AvatarSelectionBottomSheet> createState() =>
      _AvatarSelectionBottomSheetState();
}

class _AvatarSelectionBottomSheetState
    extends State<AvatarSelectionBottomSheet> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showCamera = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode error: $e');
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        debugPrint('Flash mode error: $e');
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() => _capturedImage = photo);
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final storageService = StorageService();
    final authService = AuthService();

    try {
      final image = await storageService.pickImageFromGallery();
      if (!mounted) return;

      if (image == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected')));
        return;
      }

      if (!authService.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be signed in to update avatar'),
          ),
        );
        return;
      }

      final avatarUrl = await authService.updateUserAvatar(image);

      if (!mounted) return;

      if (avatarUrl != null) {
        widget.onImageSelected(avatarUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Avatar uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _usePhoto() async {
    if (_capturedImage == null) return;

    final authService = AuthService();
    if (!authService.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to update avatar')),
      );
      return;
    }

    try {
      final avatarUrl = await authService.updateUserAvatar(_capturedImage);
      if (!mounted) return;

      if (avatarUrl != null) {
        widget.onImageSelected(avatarUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Avatar uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            if (!_showCamera) ...[
              // Title
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  'Update Profile Photo',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Options
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    _buildOptionTile(
                      icon: 'camera_alt',
                      title: 'Take Photo',
                      subtitle: 'Use camera to take a new photo',
                      onTap: () {
                        if (_isCameraInitialized) {
                          setState(() => _showCamera = true);
                        }
                      },
                    ),
                    _buildOptionTile(
                      icon: 'photo_library',
                      title: 'Choose from Gallery',
                      subtitle: 'Select from your photo library',
                      onTap: _pickFromGallery,
                    ),
                    _buildOptionTile(
                      icon: 'person_remove',
                      title: 'Remove Photo',
                      subtitle: 'Use default avatar',
                      onTap: () {
                        widget.onImageSelected('');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),
            ] else ...[
              // Camera view
              Expanded(
                child: _capturedImage != null
                    ? _buildImagePreview()
                    : _buildCameraView(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(
                alpha: 0.2,
              ),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              size: 5.w,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Initializing camera...',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showCamera = false),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  size: 6.w,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Take Photo',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SizedBox(width: 6.w),
            ],
          ),
        ),

        // Camera preview
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.hardEdge,
            child: CameraPreview(_cameraController!),
          ),
        ),

        // Controls
        Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _pickFromGallery,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'photo_library',
                    size: 6.w,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      width: 4,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'camera_alt',
                    size: 8.w,
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: _retakePhoto,
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  size: 6.w,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Preview',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SizedBox(width: 6.w),
            ],
          ),
        ),

        // Image preview
Expanded(
  child: Container(
    margin: EdgeInsets.symmetric(horizontal: 4.w),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.hardEdge,
    child: FutureBuilder<Uint8List>(
      future: _capturedImage!.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading image',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          );
        }
      },
    ),
  ),
),


        // Controls
        Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _retakePhoto,
                  child: const Text('Retake'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _usePhoto,
                  child: const Text('Use Photo'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
