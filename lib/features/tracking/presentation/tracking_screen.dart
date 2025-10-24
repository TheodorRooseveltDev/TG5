import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/providers/app_providers.dart';
import '../../settings/presentation/settings_screen.dart';
import 'active_run_screen.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyStats = ref.watch(dailyStatsProvider);
    final activeRun = ref.watch(activeRunProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Run Tracking'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.neonGreen,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Week view
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _WeekView(),
              ),

              const SizedBox(height: 32),

              // Central circular ring chart
              _CircularRingChart(
                distanceKm: dailyStats.distanceKm,
                distanceGoal: dailyStats.goalDistanceKm,
                timeMinutes: dailyStats.durationMinutes,
                timeGoal: dailyStats.goalMinutes,
                calories: dailyStats.caloriesBurned,
                caloriesGoal: dailyStats.goalCalories,
              ),

              const SizedBox(height: 32),

              // Progress bars
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ProgressBar(
                      label: 'Distance',
                      progress: dailyStats.distanceProgress,
                      color: AppColors.neonGreen,
                      currentValue: '${dailyStats.distanceKm.toStringAsFixed(1)} km',
                      goalValue: '${dailyStats.goalDistanceKm.toStringAsFixed(1)} km',
                    ),
                    const SizedBox(height: 16),
                    ProgressBar(
                      label: 'Time',
                      progress: dailyStats.timeProgress,
                      color: AppColors.purpleGradientStart,
                      currentValue: '${dailyStats.durationMinutes} min',
                      goalValue: '${dailyStats.goalMinutes} min',
                    ),
                    const SizedBox(height: 16),
                    ProgressBar(
                      label: 'Calories',
                      progress: dailyStats.caloriesProgress,
                      color: AppColors.yellowRing,
                      currentValue: '${dailyStats.caloriesBurned} kcal',
                      goalValue: '${dailyStats.goalCalories} kcal',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Daily run log section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Run Log',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Edit plan',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.neonGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Motivational card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PremiumCard(
                  backgroundColor: AppColors.secondaryCard,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_run,
                          color: AppColors.neonGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Time to hit the road! 🏃',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Start Run button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PremiumButton(
                  text: activeRun != null ? 'Resume Run' : 'Start Run',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    if (activeRun == null) {
                      ref.read(activeRunProvider.notifier).startRun();
                    }
                    // Navigate to active run screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActiveRunScreen(),
                      ),
                    );
                  },
                  width: double.infinity,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    // Calculate the start of the week (Sunday)
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = date.day == now.day && 
                       date.month == now.month && 
                       date.year == now.year;

        return Column(
          children: [
            Text(
              weekDays[date.weekday % 7],
              style: TextStyle(
                fontSize: 12,
                color: isToday ? AppColors.neonGreen : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isToday ? AppColors.neonGreen : AppColors.secondaryCard,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isToday ? Colors.black : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CircularRingChart extends StatelessWidget {
  final double distanceKm;
  final double distanceGoal;
  final int timeMinutes;
  final int timeGoal;
  final int calories;
  final int caloriesGoal;

  const _CircularRingChart({
    required this.distanceKm,
    required this.distanceGoal,
    required this.timeMinutes,
    required this.timeGoal,
    required this.calories,
    required this.caloriesGoal,
  });

  @override
  Widget build(BuildContext context) {
    final distanceProgress = (distanceKm / distanceGoal).clamp(0.0, 1.0);
    final timeProgress = (timeMinutes / timeGoal).clamp(0.0, 1.0);
    final caloriesProgress = (calories / caloriesGoal).clamp(0.0, 1.0);

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Three colored arc segments
          CustomPaint(
            size: const Size(250, 250),
            painter: _MultiRingPainter(
              distanceProgress: distanceProgress,
              timeProgress: timeProgress,
              caloriesProgress: caloriesProgress,
            ),
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Day 1',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                distanceKm.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Text(
                'km',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MultiRingPainter extends CustomPainter {
  final double distanceProgress;
  final double timeProgress;
  final double caloriesProgress;

  _MultiRingPainter({
    required this.distanceProgress,
    required this.timeProgress,
    required this.caloriesProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const strokeWidth = 16.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.cardBackground
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    const startAngle = -math.pi / 2;
    const segmentAngle = (2 * math.pi) / 3;

    // Draw three segments
    final segments = [
      {'progress': distanceProgress, 'color': AppColors.neonGreen},
      {'progress': timeProgress, 'color': AppColors.purpleGradientStart},
      {'progress': caloriesProgress, 'color': AppColors.yellowRing},
    ];

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final progress = segment['progress'] as double;
      final color = segment['color'] as Color;

      if (progress > 0) {
        final segmentStartAngle = startAngle + (segmentAngle * i);
        final sweepAngle = segmentAngle * progress;

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          segmentStartAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MultiRingPainter oldDelegate) {
    return oldDelegate.distanceProgress != distanceProgress ||
        oldDelegate.timeProgress != timeProgress ||
        oldDelegate.caloriesProgress != caloriesProgress;
  }
}
