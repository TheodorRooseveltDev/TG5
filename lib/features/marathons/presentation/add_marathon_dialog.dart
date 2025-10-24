import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/models/marathon_event.dart';

class AddMarathonDialog extends StatefulWidget {
  final MarathonEvent? event; // If editing existing event
  final Function(MarathonEvent) onSave;

  const AddMarathonDialog({
    super.key,
    this.event,
    required this.onSave,
  });

  @override
  State<AddMarathonDialog> createState() => _AddMarathonDialogState();
}

class _AddMarathonDialogState extends State<AddMarathonDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedDistance = '5K';
  bool _isReminded = false;

  final List<String> _distanceOptions = [
    '5K',
    '10K',
    'Half Marathon',
    'Full Marathon',
    'Ultra Marathon',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing event data if editing
    if (widget.event != null) {
      _nameController = TextEditingController(text: widget.event!.name);
      _addressController = TextEditingController(text: widget.event!.address);
      _descriptionController = TextEditingController(text: widget.event!.description);
      _selectedDate = widget.event!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.date);
      _selectedDistance = widget.event!.distance;
      _isReminded = widget.event!.isReminded;
    } else {
      _nameController = TextEditingController();
      _addressController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)), // 2 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonGreen,
              onPrimary: AppColors.background,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardBackground,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonGreen,
              onPrimary: AppColors.background,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardBackground,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final event = MarathonEvent(
        id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        date: eventDateTime,
        address: _addressController.text.trim(),
        distance: _selectedDistance,
        description: _descriptionController.text.trim(),
        isReminded: _isReminded,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
      );

      widget.onSave(event);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

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
                    Text(
                      widget.event != null ? 'Edit Event' : 'Add Marathon Event',
                      style: const TextStyle(
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
                const SizedBox(height: 24),

                // Event Name
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintText: 'e.g., NYC Marathon 2025',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.event, color: AppColors.neonGreen),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter event name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Distance Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDistance,
                  dropdownColor: AppColors.background,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Distance',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.straighten, color: AppColors.neonGreen),
                  ),
                  items: _distanceOptions.map((distance) {
                    return DropdownMenuItem(
                      value: distance,
                      child: Text(distance),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistance = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.neonGreen),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Picker
                InkWell(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.neonGreen),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeFormat.format(DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute)),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintText: 'e.g., Central Park, New York, NY',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.neonGreen),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description (optional)
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintText: 'Add any notes about this event...',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.notes, color: AppColors.neonGreen),
                  ),
                ),
                const SizedBox(height: 16),

                // Reminder Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: AppColors.neonGreen),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Set Reminder',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isReminded,
                        onChanged: (value) {
                          setState(() {
                            _isReminded = value;
                          });
                        },
                        activeColor: AppColors.neonGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                PremiumButton(
                  text: widget.event != null ? 'Update Event' : 'Add Event',
                  onPressed: _saveEvent,
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
