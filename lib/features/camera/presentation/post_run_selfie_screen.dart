import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/models/run_session.dart';

class PostRunSelfieScreen extends ConsumerStatefulWidget {
  final RunSession runSession;

  const PostRunSelfieScreen({
    super.key,
    required this.runSession,
  });

  @override
  ConsumerState<PostRunSelfieScreen> createState() => _PostRunSelfieScreenState();
}

class _PostRunSelfieScreenState extends ConsumerState<PostRunSelfieScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  String? _capturedImagePath;
  bool _isCapturing = false;
  String? _errorMessage;
  bool _permissionDenied = false;
  bool _isSimulator = false;

  @override
  void initState() {
    super.initState();
    _checkEnvironmentAndInitialize();
  }

  Future<void> _checkEnvironmentAndInitialize() async {
    // Check if running on simulator/emulator
    if (Platform.isIOS) {
      // iOS Simulator detection - cameras will be empty or initialization will fail
      try {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          setState(() {
            _isSimulator = true;
          });
          return;
        }
      } catch (e) {
        // If we can't get cameras, likely simulator
        setState(() {
          _isSimulator = true;
        });
        return;
      }
    }
    
    // Not a simulator or has camera access, proceed with permission request
    await _requestPermissionsAndInitialize();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    try {
      // Check current permission status
      var cameraStatus = await Permission.camera.status;
      
      // If not determined, request permission (this will show iOS dialog)
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }
      
      if (cameraStatus.isGranted) {
        await _initializeCamera();
      } else if (cameraStatus.isPermanentlyDenied) {
        setState(() {
          _permissionDenied = true;
          _errorMessage = 'Camera permission was denied. Please enable it in Settings to take a selfie.';
        });
      } else if (cameraStatus.isDenied) {
        setState(() {
          _permissionDenied = true;
          _errorMessage = 'Camera permission is required to take a victory selfie.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use front camera if available for selfie
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _errorMessage = null;
            _permissionDenied = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No camera found on this device.';
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedImagePath = image.path;
        _isCapturing = false;
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _saveSelfie() async {
    if (_capturedImagePath != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = '${directory.path}/$fileName';
        
        await File(_capturedImagePath!).copy(savedPath);
        
        if (mounted) {
          // Update run session with selfie path
          Navigator.pop(context, savedPath);
        }
      } catch (e) {
        debugPrint('Error saving selfie: $e');
      }
    }
  }

  void _retake() {
    setState(() {
      _capturedImagePath = null;
    });
  }

  void _skip() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or captured image or error state
          if (_capturedImagePath != null)
            Positioned.fill(
              child: Image.file(
                File(_capturedImagePath!),
                fit: BoxFit.cover,
              ),
            )
          else if (_isSimulator)
            // Simulator mode - show mock selfie screen
            Positioned.fill(
              child: Container(
                color: AppColors.background,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone_iphone,
                            size: 60,
                            color: AppColors.neonGreen,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Simulator Mode',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera is not available in the iOS Simulator.\n\nOn a real device, you\'ll see:\n• Native iOS permission dialog\n• Camera preview\n• Capture your victory selfie!',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        PremiumButton(
                          text: 'Skip Selfie',
                          onPressed: _skip,
                          icon: Icons.skip_next,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: AppColors.neonGreen,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Testing on Real Device',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.neonGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'The camera permission dialog will automatically appear when you finish a run on a real iPhone.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary.withOpacity(0.8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (_permissionDenied)
            // Permission denied state
            Positioned.fill(
              child: Container(
                color: AppColors.background,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.yellowRing.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: AppColors.yellowRing,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Camera Permission Required',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage ?? 'We need camera access to take your victory selfie.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        if (_permissionDenied)
                          PremiumButton(
                            text: 'Open Settings',
                            onPressed: _openSettings,
                            icon: Icons.settings,
                          )
                        else
                          PremiumButton(
                            text: 'Grant Permission',
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                                _permissionDenied = false;
                              });
                              _requestPermissionsAndInitialize();
                            },
                            icon: Icons.camera_alt,
                          ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _skip,
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (_errorMessage != null)
            // Error state
            Positioned.fill(
              child: Container(
                color: AppColors.background,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        PremiumButton(
                          text: 'Try Again',
                          onPressed: _requestPermissionsAndInitialize,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _skip,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (_isInitialized && _cameraController != null)
            // Camera preview
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            // Loading state
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.neonGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Gradient overlay for stats
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Victory Selfie! 🎉',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (_capturedImagePath == null)
                        TextButton(
                          onPressed: _skip,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Run stats overlay
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.straighten,
                        label: '${widget.runSession.distanceKm.toStringAsFixed(2)} km',
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.schedule,
                        label: '${widget.runSession.durationMinutes} min',
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.local_fire_department,
                        label: '${widget.runSession.caloriesBurned} kcal',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: _capturedImagePath != null
                  ? Row(
                      children: [
                        Expanded(
                          child: PremiumButton(
                            text: 'Retake',
                            isPrimary: false,
                            onPressed: _retake,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PremiumButton(
                            text: 'Save',
                            onPressed: _saveSelfie,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: GestureDetector(
                        onTap: _isCapturing ? null : _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.neonGreen,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _isCapturing
                                    ? AppColors.neonGreen.withOpacity(0.5)
                                    : AppColors.neonGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
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
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonGreen.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.neonGreen,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
