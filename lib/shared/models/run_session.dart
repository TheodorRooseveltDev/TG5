class RunSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceKm;
  final int durationMinutes;
  final int caloriesBurned;
  final double averagePaceMinPerKm;
  final List<LocationPoint> route;
  final String? selfieImagePath;
  final bool isCompleted;

  RunSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.distanceKm,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.averagePaceMinPerKm,
    this.route = const [],
    this.selfieImagePath,
    this.isCompleted = false,
  });

  RunSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceKm,
    int? durationMinutes,
    int? caloriesBurned,
    double? averagePaceMinPerKm,
    List<LocationPoint>? route,
    String? selfieImagePath,
    bool? isCompleted,
  }) {
    return RunSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      averagePaceMinPerKm: averagePaceMinPerKm ?? this.averagePaceMinPerKm,
      route: route ?? this.route,
      selfieImagePath: selfieImagePath ?? this.selfieImagePath,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'averagePaceMinPerKm': averagePaceMinPerKm,
      'route': route.map((e) => e.toJson()).toList(),
      'selfieImagePath': selfieImagePath,
      'isCompleted': isCompleted,
    };
  }

  factory RunSession.fromJson(Map<String, dynamic> json) {
    return RunSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      distanceKm: json['distanceKm'],
      durationMinutes: json['durationMinutes'],
      caloriesBurned: json['caloriesBurned'],
      averagePaceMinPerKm: json['averagePaceMinPerKm'],
      route: (json['route'] as List?)?.map((e) => LocationPoint.fromJson(e)).toList() ?? [],
      selfieImagePath: json['selfieImagePath'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
