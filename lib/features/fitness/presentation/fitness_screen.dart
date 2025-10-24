import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/providers/app_providers.dart';
import '../../settings/presentation/settings_screen.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final allRuns = ref.watch(runSessionsProvider);

    // Calculate personal records
    final bestDistance = allRuns.isEmpty ? 0.0 : allRuns.map((r) => r.distanceKm).reduce((a, b) => a > b ? a : b);
    final fastestPace = allRuns.isEmpty ? 0.0 : allRuns.map((r) => r.averagePaceMinPerKm).reduce((a, b) => a < b && a > 0 ? a : b);
    final longestRun = allRuns.isEmpty ? 0 : allRuns.map((r) => r.durationMinutes).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.neonGreen, AppColors.cyanRing],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.insights,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Training Insights',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Your performance analytics',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  ],
                ),
              ),
            ),

            // Personal Records
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, size: 20, color: AppColors.neonGreen),
                    SizedBox(width: 8),
                    Text(
                      'Personal Records',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _RecordCard(
                        icon: Icons.social_distance,
                        label: 'Best Distance',
                        value: bestDistance.toStringAsFixed(2),
                        unit: 'km',
                        color: AppColors.cyanRing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RecordCard(
                        icon: Icons.speed,
                        label: 'Fastest Pace',
                        value: fastestPace > 0 ? fastestPace.toStringAsFixed(2) : '--',
                        unit: 'min/km',
                        color: AppColors.orangeRing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RecordCard(
                        icon: Icons.timer,
                        label: 'Longest Run',
                        value: longestRun.toString(),
                        unit: 'min',
                        color: AppColors.yellowRing,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lifetime Stats
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, size: 20, color: AppColors.neonGreen),
                    SizedBox(width: 8),
                    Text(
                      'Lifetime Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PremiumCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _StatRow(
                          icon: Icons.directions_run,
                          label: 'Total Runs',
                          value: '${userProfile?.totalRuns ?? 0}',
                          color: AppColors.neonGreen,
                        ),
                        const SizedBox(height: 16),
                        _StatRow(
                          icon: Icons.map,
                          label: 'Total Distance',
                          value: '${(userProfile?.totalDistanceKm ?? 0).toStringAsFixed(1)} km',
                          color: AppColors.cyanRing,
                        ),
                        const SizedBox(height: 16),
                        _StatRow(
                          icon: Icons.access_time,
                          label: 'Total Time',
                          value: '${userProfile?.totalMinutes ?? 0} min',
                          color: AppColors.yellowRing,
                        ),
                        const SizedBox(height: 16),
                        _StatRow(
                          icon: Icons.local_fire_department,
                          label: 'Total Calories',
                          value: '${userProfile?.totalCalories ?? 0} kcal',
                          color: AppColors.orangeRing,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Training Zones
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.speed, size: 20, color: AppColors.neonGreen),
                    SizedBox(width: 8),
                    Text(
                      'Training Zones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _TrainingZoneCard(
                      zone: 'Easy Run',
                      description: 'Recovery & base building',
                      paceRange: '6:00 - 7:00 min/km',
                      color: AppColors.greenGradientEnd,
                    ),
                    const SizedBox(height: 12),
                    _TrainingZoneCard(
                      zone: 'Tempo Run',
                      description: 'Comfortable hard pace',
                      paceRange: '5:00 - 5:45 min/km',
                      color: AppColors.yellowRing,
                    ),
                    const SizedBox(height: 12),
                    _TrainingZoneCard(
                      zone: 'Interval Training',
                      description: 'High intensity bursts',
                      paceRange: '4:00 - 4:45 min/km',
                      color: AppColors.orangeRing,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// Personal Record Card Widget
class _RecordCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _RecordCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Stat Row Widget
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Training Zone Card
class _TrainingZoneCard extends StatelessWidget {
  final String zone;
  final String description;
  final String paceRange;
  final Color color;

  const _TrainingZoneCard({
    required this.zone,
    required this.description,
    required this.paceRange,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            paceRange,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
