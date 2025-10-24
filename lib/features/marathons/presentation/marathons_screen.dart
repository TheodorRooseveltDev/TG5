import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/models/marathon_event.dart';
import '../../settings/presentation/settings_screen.dart';
import 'add_marathon_dialog.dart';

class MarathonsScreen extends ConsumerWidget {
  const MarathonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marathonEvents = ref.watch(marathonEventsProvider);
    final upcomingEvents = marathonEvents.where((e) => e.isUpcoming).toList();
    final pastEvents = marathonEvents.where((e) => !e.isUpcoming).toList();

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marathon Events',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Track your racing goals',
                                style: TextStyle(
                                  fontSize: 16,
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
                    const SizedBox(height: 24),
                    // Add Event Button
                    PremiumButton(
                      text: 'Add Marathon Event',
                      onPressed: () => _showAddEventDialog(context, ref),
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming Events Section
            if (upcomingEvents.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.upcoming,
                        size: 20,
                        color: AppColors.neonGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Upcoming Events (${upcomingEvents.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = upcomingEvents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventCard(
                          event: event,
                          isUpcoming: true,
                          onTap: () => _showEditEventDialog(context, ref, event),
                          onDelete: () => _deleteEvent(ref, event.id),
                          onToggleReminder: () => ref.read(marathonEventsProvider.notifier).toggleReminder(event.id),
                        ),
                      );
                    },
                    childCount: upcomingEvents.length,
                  ),
                ),
              ),
            ] else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PremiumCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              size: 40,
                              color: AppColors.neonGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Upcoming Events',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first marathon event to start tracking your racing goals!',
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
                ),
              ),
            ],

            // Past Events Section
            if (pastEvents.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Past Events (${pastEvents.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = pastEvents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventCard(
                          event: event,
                          isUpcoming: false,
                          onTap: () => _showEditEventDialog(context, ref, event),
                          onDelete: () => _deleteEvent(ref, event.id),
                          onToggleReminder: () => ref.read(marathonEventsProvider.notifier).toggleReminder(event.id),
                        ),
                      );
                    },
                    childCount: pastEvents.length,
                  ),
                ),
              ),
            ],

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddMarathonDialog(
        onSave: (event) {
          ref.read(marathonEventsProvider.notifier).addEvent(event);
        },
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, WidgetRef ref, MarathonEvent event) {
    showDialog(
      context: context,
      builder: (context) => AddMarathonDialog(
        event: event,
        onSave: (updatedEvent) {
          ref.read(marathonEventsProvider.notifier).updateEvent(updatedEvent);
        },
      ),
    );
  }

  void _deleteEvent(WidgetRef ref, String eventId) {
    ref.read(marathonEventsProvider.notifier).deleteEvent(eventId);
  }
}

class _EventCard extends StatelessWidget {
  final MarathonEvent event;
  final bool isUpcoming;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleReminder;

  const _EventCard({
    required this.event,
    required this.isUpcoming,
    required this.onTap,
    required this.onDelete,
    required this.onToggleReminder,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return PremiumCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                event.distance,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neonGreen,
                                ),
                              ),
                            ),
                            if (isUpcoming && event.daysUntil >= 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: event.isToday 
                                      ? AppColors.orangeRing.withOpacity(0.2)
                                      : AppColors.cyanRing.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  event.isToday ? 'TODAY' : '${event.daysUntil}d away',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: event.isToday ? AppColors.orangeRing : AppColors.cyanRing,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleReminder,
                    icon: Icon(
                      event.isReminded ? Icons.notifications_active : Icons.notifications_none,
                      color: event.isReminded ? AppColors.neonGreen : AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(event.date)} at ${timeFormat.format(event.date)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
