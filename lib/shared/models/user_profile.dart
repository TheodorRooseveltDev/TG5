class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final int currentStreak;
  final int bestStreak;
  final int totalRuns;
  final double totalDistanceKm;
  final int totalMinutes;
  final int totalCalories;
  final DateTime? lastRunDate;

  UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalRuns = 0,
    this.totalDistanceKm = 0.0,
    this.totalMinutes = 0,
    this.totalCalories = 0,
    this.lastRunDate,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? currentStreak,
    int? bestStreak,
    int? totalRuns,
    double? totalDistanceKm,
    int? totalMinutes,
    int? totalCalories,
    DateTime? lastRunDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalRuns: totalRuns ?? this.totalRuns,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      totalCalories: totalCalories ?? this.totalCalories,
      lastRunDate: lastRunDate ?? this.lastRunDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalRuns': totalRuns,
      'totalDistanceKm': totalDistanceKm,
      'totalMinutes': totalMinutes,
      'totalCalories': totalCalories,
      'lastRunDate': lastRunDate?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      totalRuns: json['totalRuns'] ?? 0,
      totalDistanceKm: json['totalDistanceKm'] ?? 0.0,
      totalMinutes: json['totalMinutes'] ?? 0,
      totalCalories: json['totalCalories'] ?? 0,
      lastRunDate: json['lastRunDate'] != null ? DateTime.parse(json['lastRunDate']) : null,
    );
  }
}
