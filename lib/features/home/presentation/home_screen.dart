import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/circular_progress_ring.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/providers/app_providers.dart';
import '../../settings/presentation/settings_screen.dart';
import 'edit_weekly_goals_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final dailyStats = ref.watch(dailyStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with greeting and avatar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.neonGreen,
                      child: Text(
                        userProfile?.name[0].toUpperCase() ?? 'R',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            userProfile?.name ?? 'Rabbit Runner',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
              ),
            ),

            // Daily stats card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Daily Running',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircularProgressRing(
                            progress: dailyStats.distanceProgress,
                            color: AppColors.orangeRing,
                            value: dailyStats.distanceKm.toStringAsFixed(1),
                            label: 'km',
                          ),
                          CircularProgressRing(
                            progress: dailyStats.timeProgress,
                            color: AppColors.cyanRing,
                            value: dailyStats.durationMinutes.toString(),
                            label: 'min',
                          ),
                          CircularProgressRing(
                            progress: dailyStats.caloriesProgress,
                            color: AppColors.yellowRing,
                            value: dailyStats.caloriesBurned.toString(),
                            label: 'kcal',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Streak info
            if (userProfile != null && userProfile.currentStreak > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: PremiumCard(
                    backgroundColor: AppColors.secondaryCard,
                    padding: const EdgeInsets.all(16),
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
                            Icons.local_fire_department,
                            color: AppColors.neonGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${userProfile.currentStreak} Day Streak!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Keep it up! Don\'t break the chain.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
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

            // Weekly Goal Progress Diagram
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _WeeklyGoalDiagram(),
              ),
            ),

            // Recent Activity Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: AppColors.neonGreen,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Recent Activity',
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

            // Recent Runs (last 3 runs)
            SliverToBoxAdapter(
              child: _RecentRunsWidget(),
            ),

            // Weekly Summary
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 20,
                      color: AppColors.neonGreen,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'This Week',
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
              child: _WeeklySummaryWidget(),
            ),

            // Upcoming Marathon Events
            SliverToBoxAdapter(
              child: _UpcomingMarathonsWidget(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// Recent Runs Widget - shows last 3 runs with real data
class _RecentRunsWidget extends ConsumerWidget {
  const _RecentRunsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRuns = ref.watch(runSessionsProvider);
    final recentRuns = allRuns.take(3).toList();

    if (recentRuns.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: PremiumCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    size: 32,
                    color: AppColors.neonGreen,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Runs Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start your first run to see your activity here!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: recentRuns.map((run) {
        final dateFormat = DateFormat('MMM dd, yyyy');
        final timeFormat = DateFormat('h:mm a');
        final paceFormat = run.averagePaceMinPerKm.toStringAsFixed(2);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: PremiumCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Run icon or selfie thumbnail
                  if (run.selfieImagePath != null && run.selfieImagePath!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(run.selfieImagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_run,
                        color: AppColors.neonGreen,
                        size: 28,
                      ),
                    ),
                  const SizedBox(width: 16),
                  // Run details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${run.distanceKm.toStringAsFixed(2)} km run',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${run.durationMinutes} min',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.speed,
                              size: 14,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$paceFormat min/km',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dateFormat.format(run.startTime)} at ${timeFormat.format(run.startTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calories badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.orangeRing.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${run.caloriesBurned}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orangeRing,
                          ),
                        ),
                        const Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.orangeRing,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Weekly Summary Widget - shows this week's totals
class _WeeklySummaryWidget extends ConsumerWidget {
  const _WeeklySummaryWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRuns = ref.watch(runSessionsProvider);
    
    // Calculate this week's stats
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    final thisWeekRuns = allRuns.where((run) {
      final runDate = DateTime(run.startTime.year, run.startTime.month, run.startTime.day);
      return runDate.isAfter(weekStartDate.subtract(const Duration(days: 1)));
    }).toList();

    final totalDistance = thisWeekRuns.fold(0.0, (sum, run) => sum + run.distanceKm);
    final totalTime = thisWeekRuns.fold(0, (sum, run) => sum + run.durationMinutes);
    final totalCalories = thisWeekRuns.fold(0, (sum, run) => sum + run.caloriesBurned);
    final runsCount = thisWeekRuns.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PremiumCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _WeekStatItem(
                      icon: Icons.directions_run,
                      label: 'Runs',
                      value: runsCount.toString(),
                      color: AppColors.neonGreen,
                    ),
                  ),
                  Expanded(
                    child: _WeekStatItem(
                      icon: Icons.social_distance,
                      label: 'Distance',
                      value: '${totalDistance.toStringAsFixed(1)} km',
                      color: AppColors.cyanRing,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _WeekStatItem(
                      icon: Icons.timer,
                      label: 'Time',
                      value: '${totalTime} min',
                      color: AppColors.yellowRing,
                    ),
                  ),
                  Expanded(
                    child: _WeekStatItem(
                      icon: Icons.local_fire_department,
                      label: 'Calories',
                      value: '$totalCalories',
                      color: AppColors.orangeRing,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeekStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Upcoming Marathons Widget - shows next 2 events
class _UpcomingMarathonsWidget extends ConsumerWidget {
  const _UpcomingMarathonsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marathonEvents = ref.watch(marathonEventsProvider);
    final upcomingEvents = marathonEvents
        .where((e) => e.isUpcoming)
        .take(2)
        .toList();

    if (upcomingEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 20,
                color: AppColors.neonGreen,
              ),
              SizedBox(width: 8),
              Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...upcomingEvents.map((event) {
          final daysUntil = event.daysUntil;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: PremiumCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Date badge
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.neonGreen,
                            AppColors.neonGreen.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            event.date.day.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            DateFormat('MMM').format(event.date).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Event details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.cyanRing.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.distance,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cyanRing,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Days countdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.isToday 
                            ? AppColors.orangeRing.withOpacity(0.2)
                            : AppColors.yellowRing.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            event.isToday ? 'TODAY' : daysUntil.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: event.isToday ? AppColors.orangeRing : AppColors.yellowRing,
                            ),
                          ),
                          if (!event.isToday)
                            Text(
                              'days',
                              style: TextStyle(
                                fontSize: 10,
                                color: event.isToday ? AppColors.orangeRing : AppColors.yellowRing,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Weekly Goal Diagram - Circular progress showing week goals
class _WeeklyGoalDiagram extends ConsumerWidget {
  const _WeeklyGoalDiagram();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRuns = ref.watch(runSessionsProvider);
    final weeklyGoals = ref.watch(weeklyGoalsProvider);
    
    // Calculate this week's stats
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    final thisWeekRuns = allRuns.where((run) {
      final runDate = DateTime(run.startTime.year, run.startTime.month, run.startTime.day);
      return runDate.isAfter(weekStartDate.subtract(const Duration(days: 1)));
    }).toList();

    final totalDistance = thisWeekRuns.fold(0.0, (sum, run) => sum + run.distanceKm);
    final totalTime = thisWeekRuns.fold(0, (sum, run) => sum + run.durationMinutes);
    final runsCount = thisWeekRuns.length;

    // Get goals from provider
    final goalDistance = weeklyGoals.distanceKm;
    final goalTime = weeklyGoals.minutes;
    final goalRuns = weeklyGoals.runsCount;

    final distanceProgress = (totalDistance / goalDistance).clamp(0.0, 1.0);
    final timeProgress = (totalTime / goalTime).clamp(0.0, 1.0);
    final runsProgress = (runsCount / goalRuns).clamp(0.0, 1.0);

    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.track_changes,
                  size: 20,
                  color: AppColors.neonGreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Weekly Goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const EditWeeklyGoalsDialog(),
                    );
                  },
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.neonGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Circular diagram
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring - Distance
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: distanceProgress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.secondaryCard,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyanRing),
                    ),
                  ),
                  // Middle ring - Time
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: timeProgress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.secondaryCard,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yellowRing),
                    ),
                  ),
                  // Inner ring - Runs
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: runsProgress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.secondaryCard,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${((distanceProgress + timeProgress + runsProgress) / 3 * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _GoalLegendItem(
                  color: AppColors.cyanRing,
                  label: 'Distance',
                  current: totalDistance.toStringAsFixed(1),
                  goal: goalDistance.toStringAsFixed(0),
                  unit: 'km',
                ),
                _GoalLegendItem(
                  color: AppColors.yellowRing,
                  label: 'Time',
                  current: totalTime.toString(),
                  goal: goalTime.toString(),
                  unit: 'min',
                ),
                _GoalLegendItem(
                  color: AppColors.neonGreen,
                  label: 'Runs',
                  current: runsCount.toString(),
                  goal: goalRuns.toString(),
                  unit: 'runs',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String current;
  final String goal;
  final String unit;

  const _GoalLegendItem({
    required this.color,
    required this.label,
    required this.current,
    required this.goal,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: current,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              TextSpan(
                text: ' / $goal',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
