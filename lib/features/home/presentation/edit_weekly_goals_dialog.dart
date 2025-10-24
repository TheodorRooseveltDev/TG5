import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/models/weekly_goals.dart';
import '../../../shared/providers/app_providers.dart';

class EditWeeklyGoalsDialog extends ConsumerStatefulWidget {
  const EditWeeklyGoalsDialog({super.key});

  @override
  ConsumerState<EditWeeklyGoalsDialog> createState() => _EditWeeklyGoalsDialogState();
}

class _EditWeeklyGoalsDialogState extends ConsumerState<EditWeeklyGoalsDialog> {
  late TextEditingController _distanceController;
  late TextEditingController _timeController;
  late TextEditingController _runsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final currentGoals = ref.read(weeklyGoalsProvider);
    _distanceController = TextEditingController(text: currentGoals.distanceKm.toStringAsFixed(0));
    _timeController = TextEditingController(text: currentGoals.minutes.toString());
    _runsController = TextEditingController(text: currentGoals.runsCount.toString());
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _timeController.dispose();
    _runsController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    if (_formKey.currentState!.validate()) {
      final newGoals = WeeklyGoals(
        distanceKm: double.parse(_distanceController.text),
        minutes: int.parse(_timeController.text),
        runsCount: int.parse(_runsController.text),
      );
      
      ref.read(weeklyGoalsProvider.notifier).updateGoals(newGoals);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Set Weekly Goals',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Challenge yourself with custom weekly targets',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Distance Goal
                _GoalInputField(
                  controller: _distanceController,
                  label: 'Distance Goal',
                  unit: 'km',
                  icon: Icons.social_distance,
                  color: AppColors.cyanRing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter distance';
                    }
                    final distance = double.tryParse(value);
                    if (distance == null || distance <= 0) {
                      return 'Please enter a valid distance';
                    }
                    if (distance > 200) {
                      return 'Maximum 200 km per week';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Time Goal
                _GoalInputField(
                  controller: _timeController,
                  label: 'Time Goal',
                  unit: 'minutes',
                  icon: Icons.timer,
                  color: AppColors.yellowRing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter time';
                    }
                    final time = int.tryParse(value);
                    if (time == null || time <= 0) {
                      return 'Please enter a valid time';
                    }
                    if (time > 1000) {
                      return 'Maximum 1000 minutes per week';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Runs Goal
                _GoalInputField(
                  controller: _runsController,
                  label: 'Number of Runs',
                  unit: 'runs',
                  icon: Icons.directions_run,
                  color: AppColors.neonGreen,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of runs';
                    }
                    final runs = int.tryParse(value);
                    if (runs == null || runs <= 0) {
                      return 'Please enter a valid number';
                    }
                    if (runs > 30) {
                      return 'Maximum 30 runs per week';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Quick presets
                const Text(
                  'Quick Presets',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PresetChip(
                      label: 'Beginner',
                      onTap: () {
                        setState(() {
                          _distanceController.text = '10';
                          _timeController.text = '60';
                          _runsController.text = '3';
                        });
                      },
                    ),
                    _PresetChip(
                      label: 'Intermediate',
                      onTap: () {
                        setState(() {
                          _distanceController.text = '20';
                          _timeController.text = '150';
                          _runsController.text = '5';
                        });
                      },
                    ),
                    _PresetChip(
                      label: 'Advanced',
                      onTap: () {
                        setState(() {
                          _distanceController.text = '40';
                          _timeController.text = '300';
                          _runsController.text = '7';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save button
                PremiumButton(
                  text: 'Save Goals',
                  onPressed: _saveGoals,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final String? Function(String?)? validator;

  const _GoalInputField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        suffixText: unit,
        suffixStyle: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: color),
      ),
      validator: validator,
    );
  }
}

class _PresetChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  State<_PresetChip> createState() => _PresetChipState();
}

class _PresetChipState extends State<_PresetChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppColors.background,
      end: AppColors.neonGreen.withOpacity(0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.neonGreen.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: _controller.value > 0.1
                    ? [
                        BoxShadow(
                          color: AppColors.neonGreen.withOpacity(0.3 * _controller.value),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neonGreen,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
