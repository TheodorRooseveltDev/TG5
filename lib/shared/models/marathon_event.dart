class MarathonEvent {
  final String id;
  final String name;
  final DateTime date;
  final String address;
  final String distance; // e.g., "5K", "10K", "Half Marathon", "Full Marathon"
  final String description;
  final bool isReminded;
  final DateTime createdAt;

  MarathonEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.address,
    required this.distance,
    this.description = '',
    this.isReminded = false,
    required this.createdAt,
  });

  // Helper to check if event is upcoming
  bool get isUpcoming => date.isAfter(DateTime.now());

  // Helper to check if event is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Helper to get days until event
  int get daysUntil {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // Copy with method
  MarathonEvent copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? address,
    String? distance,
    String? description,
    bool? isReminded,
    DateTime? createdAt,
  }) {
    return MarathonEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      description: description ?? this.description,
      isReminded: isReminded ?? this.isReminded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'address': address,
      'distance': distance,
      'description': description,
      'isReminded': isReminded,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MarathonEvent.fromJson(Map<String, dynamic> json) {
    return MarathonEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      address: json['address'] as String,
      distance: json['distance'] as String,
      description: json['description'] as String? ?? '',
      isReminded: json['isReminded'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
