import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/gps_tracking_service.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/providers/app_providers.dart';
import '../../camera/presentation/post_run_selfie_screen.dart';

class ActiveRunScreen extends ConsumerStatefulWidget {
  const ActiveRunScreen({super.key});

  @override
  ConsumerState<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends ConsumerState<ActiveRunScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  double _distanceKm = 0.0;
  int _caloriesBurned = 0;
  String _currentPace = '--:--';
  
  final GPSTrackingService _gpsService = GPSTrackingService();
  StreamSubscription<double>? _distanceSubscription;
  StreamSubscription<double>? _speedSubscription;
  StreamSubscription<String>? _paceSubscription;

  @override
  void initState() {
    super.initState();
    _initializeGPS();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _distanceSubscription?.cancel();
    _speedSubscription?.cancel();
    _paceSubscription?.cancel();
    _gpsService.stopTracking();
    _gpsService.dispose();
    super.dispose();
  }

  Future<void> _initializeGPS() async {
    // Try to start GPS tracking
    bool started = await _gpsService.startTracking();
    
    if (started) {
      // Listen to distance updates
      _distanceSubscription = _gpsService.distanceStream.listen((distance) {
        setState(() {
          _distanceKm = distance;
          _caloriesBurned = (_distanceKm * 65).round();
        });
        
        // Update the active run provider
        ref.read(activeRunProvider.notifier).updateRun(
          distanceKm: _distanceKm,
          durationMinutes: (_elapsedSeconds / 60).floor(),
          caloriesBurned: _caloriesBurned,
          averagePaceMinPerKm: _distanceKm > 0 
              ? (_elapsedSeconds / 60) / _distanceKm 
              : 0,
        );
      });
      
      // Listen to speed updates (for future use)
      _speedSubscription = _gpsService.speedStream.listen((speed) {
        // Speed updates available for UI if needed
      });
      
      // Listen to pace updates (real-time pace from GPS)
      _paceSubscription = _gpsService.paceStream.listen((pace) {
        setState(() {
          _currentPace = pace;
        });
      });
      
      _startTimer();
    } else {
      // Show error dialog
      if (mounted) {
        _showGPSError();
      }
    }
  }

  void _showGPSError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Location Required',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'GPS tracking is required to measure your running distance. Please enable location services and grant permission.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _gpsService.openAppSettings();
            },
            child: const Text(
              'Settings',
              style: TextStyle(color: AppColors.neonGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;
          
          // Simulator fallback: If no GPS distance after 5 seconds, simulate it
          // This helps testing on iOS simulator where GPS doesn't work
          if (_elapsedSeconds > 5 && _distanceKm == 0) {
            _distanceKm += 0.002; // Simulate ~7.2 km/h pace
            _caloriesBurned = (_distanceKm * 65).round();
          }
        });

        // Update the active run provider with current time
        ref.read(activeRunProvider.notifier).updateRun(
          distanceKm: _distanceKm,
          durationMinutes: (_elapsedSeconds / 60).floor(),
          caloriesBurned: _caloriesBurned,
          averagePaceMinPerKm: _distanceKm > 0 
              ? (_elapsedSeconds / 60) / _distanceKm 
              : 0,
        );
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _gpsService.pauseTracking();
    } else {
      _gpsService.resumeTracking();
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatPace() {
    // If GPS pace is available and valid, use it
    if (_currentPace != '--:--') {
      return _currentPace;
    }
    
    // Fallback: Calculate pace from elapsed time and distance
    // (Used on simulator or when GPS pace isn't available)
    if (_distanceKm == 0) return '--:--';
    final paceMinPerKm = (_elapsedSeconds / 60) / _distanceKm;
    final minutes = paceMinPerKm.floor();
    final seconds = ((paceMinPerKm - minutes) * 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _stopRun() async {
    _timer?.cancel();
    await _gpsService.stopTracking();
    
    // Complete the run
    final activeRun = ref.read(activeRunProvider);
    if (activeRun != null) {
      ref.read(activeRunProvider.notifier).completeRun();
      
      // Navigate to selfie screen
      final selfiePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => PostRunSelfieScreen(
            runSession: activeRun.copyWith(
              distanceKm: _distanceKm,
              durationMinutes: (_elapsedSeconds / 60).floor(),
              caloriesBurned: _caloriesBurned,
              endTime: DateTime.now(),
              isCompleted: true,
            ),
          ),
        ),
      );
      
      // Save the run with selfie path
      final completedRun = activeRun.copyWith(
        distanceKm: _distanceKm,
        durationMinutes: (_elapsedSeconds / 60).floor(),
        caloriesBurned: _caloriesBurned,
        averagePaceMinPerKm: _distanceKm > 0 
            ? (_elapsedSeconds / 60) / _distanceKm 
            : 0,
        endTime: DateTime.now(),
        isCompleted: true,
        selfieImagePath: selfiePath,
      );
      
      // Save to history
      await ref.read(runSessionsProvider.notifier).addSession(completedRun);
      
      // Update daily stats
      await ref.read(dailyStatsProvider.notifier).addRunStats(
        distanceKm: _distanceKm,
        minutes: (_elapsedSeconds / 60).floor(),
        calories: _caloriesBurned,
      );
      
      // Update user profile
      await ref.read(userProfileProvider.notifier).incrementStats(
        distanceKm: _distanceKm,
        minutes: (_elapsedSeconds / 60).floor(),
        calories: _caloriesBurned,
      );
      
      // Clear active run
      ref.read(activeRunProvider.notifier).cancelRun();
      
      if (mounted) {
        // Go back to main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  void _confirmStop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'End Run?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to end this run?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _stopRun();
            },
            child: const Text(
              'End Run',
              style: TextStyle(color: AppColors.neonGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Running...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isPaused 
                          ? AppColors.yellowRing.withOpacity(0.2)
                          : AppColors.neonGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isPaused 
                                ? AppColors.yellowRing 
                                : AppColors.neonGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isPaused ? 'Paused' : 'Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isPaused 
                                ? AppColors.yellowRing 
                                : AppColors.neonGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Main stats
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Distance
                  Text(
                    _distanceKm.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neonGreen,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Text(
                    'KILOMETERS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Time and Pace
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatColumn(
                          label: 'TIME',
                          value: _formatTime(_elapsedSeconds),
                          icon: Icons.schedule,
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: AppColors.secondaryCard,
                        ),
                        _StatColumn(
                          label: 'PACE',
                          value: _formatPace(),
                          unit: '/km',
                          icon: Icons.speed,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Calories
                  PremiumCard(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    backgroundColor: AppColors.secondaryCard,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: AppColors.yellowRing,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_caloriesBurned',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      text: _isPaused ? 'Resume' : 'Pause',
                      icon: _isPaused ? Icons.play_arrow : Icons.pause,
                      onPressed: _togglePause,
                      isPrimary: false,
                      height: 56,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PremiumButton(
                      text: 'Finish',
                      icon: Icons.stop,
                      onPressed: _confirmStop,
                      height: 56,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;

  const _StatColumn({
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
