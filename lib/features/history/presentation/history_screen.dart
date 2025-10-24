import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/models/run_session.dart';
import '../../settings/presentation/settings_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _expandedRunId;

  @override
  Widget build(BuildContext context) {
    final runSessions = ref.watch(runSessionsProvider);
    final datesWithRuns = ref.read(runSessionsProvider.notifier).getDatesWithRuns();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Run History'),
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
        child: CustomScrollView(
          slivers: [
            // Mini calendar view
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _MiniCalendar(
                  selectedDate: _selectedDate,
                  datesWithRuns: datesWithRuns,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),
            ),

            // Stats summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PremiumCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                        icon: Icons.directions_run,
                        value: runSessions.length.toString(),
                        label: 'Total Runs',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.secondaryCard,
                      ),
                      _SummaryItem(
                        icon: Icons.straighten,
                        value: runSessions
                            .fold<double>(0, (sum, run) => sum + run.distanceKm)
                            .toStringAsFixed(1),
                        label: 'Total KM',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.secondaryCard,
                      ),
                      _SummaryItem(
                        icon: Icons.schedule,
                        value: (runSessions
                            .fold<int>(0, (sum, run) => sum + run.durationMinutes) ~/ 60)
                            .toString(),
                        label: 'Hours',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // List of runs
            runSessions.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_run,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No runs yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start your first run to see it here!',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final run = runSessions[index];
                        final isExpanded = _expandedRunId == run.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: _RunHistoryCard(
                            run: run,
                            isExpanded: isExpanded,
                            onTap: () {
                              setState(() {
                                _expandedRunId = isExpanded ? null : run.id;
                              });
                            },
                          ),
                        );
                      },
                      childCount: runSessions.length,
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> datesWithRuns;
  final Function(DateTime) onDateSelected;

  const _MiniCalendar({
    required this.selectedDate,
    required this.datesWithRuns,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(now),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(now.year, now.month, day);
              final hasRun = datesWithRuns.any((d) =>
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day);
              final isToday = date.day == now.day &&
                  date.month == now.month &&
                  date.year == now.year;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.neonGreen
                        : (hasRun ? AppColors.secondaryCard : Colors.transparent),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isToday
                              ? Colors.black
                              : (hasRun ? AppColors.neonGreen : AppColors.textSecondary),
                        ),
                      ),
                      if (hasRun && !isToday)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.neonGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.neonGreen,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RunHistoryCard extends StatelessWidget {
  final RunSession run;
  final bool isExpanded;
  final VoidCallback onTap;

  const _RunHistoryCard({
    required this.run,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return PremiumCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Selfie thumbnail
              if (run.selfieImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(run.selfieImagePath!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    color: AppColors.neonGreen,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(run.startTime),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MiniStat(
                          icon: Icons.straighten,
                          value: '${run.distanceKm.toStringAsFixed(2)}km',
                        ),
                        const SizedBox(width: 16),
                        _MiniStat(
                          icon: Icons.schedule,
                          value: '${run.durationMinutes}min',
                        ),
                        const SizedBox(width: 16),
                        _MiniStat(
                          icon: Icons.local_fire_department,
                          value: '${run.caloriesBurned}kcal',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          // Expanded details
          if (isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.secondaryCard),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailStat(
                  label: 'Avg Pace',
                  value: '${run.averagePaceMinPerKm.toStringAsFixed(2)}',
                  unit: 'min/km',
                ),
                _DetailStat(
                  label: 'Duration',
                  value: '${run.durationMinutes}',
                  unit: 'minutes',
                ),
                _DetailStat(
                  label: 'Calories',
                  value: '${run.caloriesBurned}',
                  unit: 'kcal',
                ),
              ],
            ),
            if (run.selfieImagePath != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(run.selfieImagePath!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: AppColors.secondaryCard,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _DetailStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
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
