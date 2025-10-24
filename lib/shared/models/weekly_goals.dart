class WeeklyGoals {
  final double distanceKm;
  final int minutes;
  final int runsCount;

  WeeklyGoals({
    this.distanceKm = 20.0,
    this.minutes = 150,
    this.runsCount = 5,
  });

  WeeklyGoals copyWith({
    double? distanceKm,
    int? minutes,
    int? runsCount,
  }) {
    return WeeklyGoals(
      distanceKm: distanceKm ?? this.distanceKm,
      minutes: minutes ?? this.minutes,
      runsCount: runsCount ?? this.runsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distanceKm': distanceKm,
      'minutes': minutes,
      'runsCount': runsCount,
    };
  }

  factory WeeklyGoals.fromJson(Map<String, dynamic> json) {
    return WeeklyGoals(
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 20.0,
      minutes: json['minutes'] as int? ?? 150,
      runsCount: json['runsCount'] as int? ?? 5,
    );
  }
}
