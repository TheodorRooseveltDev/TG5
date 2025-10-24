import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../models/daily_stats.dart';
import '../models/run_session.dart';
import '../models/marathon_event.dart';
import '../models/weekly_goals.dart';

// User profile provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    
    if (profileJson != null) {
      state = UserProfile.fromJson(json.decode(profileJson));
    } else {
      // Create default profile
      state = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Rabbit Runner',
      );
      await _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    if (state != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(state!.toJson()));
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = profile;
    await _saveProfile();
  }

  Future<void> updateName(String name) async {
    if (state != null) {
      state = state!.copyWith(name: name);
      await _saveProfile();
    }
  }

  Future<void> incrementStats({
    required double distanceKm,
    required int minutes,
    required int calories,
  }) async {
    if (state != null) {
      final now = DateTime.now();
      final lastRun = state!.lastRunDate;
      
      // Update streak
      int newStreak = state!.currentStreak;
      if (lastRun != null) {
        final daysDifference = now.difference(lastRun).inDays;
        if (daysDifference == 1) {
          newStreak += 1;
        } else if (daysDifference > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      state = state!.copyWith(
        totalRuns: state!.totalRuns + 1,
        totalDistanceKm: state!.totalDistanceKm + distanceKm,
        totalMinutes: state!.totalMinutes + minutes,
        totalCalories: state!.totalCalories + calories,
        currentStreak: newStreak,
        bestStreak: newStreak > state!.bestStreak ? newStreak : state!.bestStreak,
        lastRunDate: now,
      );
      await _saveProfile();
    }
  }
}

// Daily stats provider
final dailyStatsProvider = StateNotifierProvider<DailyStatsNotifier, DailyStats>((ref) {
  return DailyStatsNotifier();
});

class DailyStatsNotifier extends StateNotifier<DailyStats> {
  DailyStatsNotifier() : super(DailyStats(date: DateTime.now())) {
    _loadDailyStats();
  }

  Future<void> _loadDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final statsJson = prefs.getString('daily_stats_$dateKey');
    
    if (statsJson != null) {
      state = DailyStats.fromJson(json.decode(statsJson));
    }
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '${state.date.year}-${state.date.month}-${state.date.day}';
    await prefs.setString('daily_stats_$dateKey', json.encode(state.toJson()));
  }

  Future<void> addRunStats({
    required double distanceKm,
    required int minutes,
    required int calories,
  }) async {
    state = state.copyWith(
      distanceKm: state.distanceKm + distanceKm,
      durationMinutes: state.durationMinutes + minutes,
      caloriesBurned: state.caloriesBurned + calories,
    );
    await _saveStats();
  }

  Future<void> updateGoals({
    double? distanceKm,
    int? minutes,
    int? calories,
  }) async {
    state = state.copyWith(
      goalDistanceKm: distanceKm,
      goalMinutes: minutes,
      goalCalories: calories,
    );
    await _saveStats();
  }
}

// Run sessions provider (list of all runs)
final runSessionsProvider = StateNotifierProvider<RunSessionsNotifier, List<RunSession>>((ref) {
  return RunSessionsNotifier();
});

class RunSessionsNotifier extends StateNotifier<List<RunSession>> {
  RunSessionsNotifier() : super([]) {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('run_sessions');
    
    if (sessionsJson != null) {
      final List<dynamic> decoded = json.decode(sessionsJson);
      state = decoded.map((e) => RunSession.fromJson(e)).toList();
    }
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(state.map((e) => e.toJson()).toList());
    await prefs.setString('run_sessions', encoded);
  }

  Future<void> addSession(RunSession session) async {
    state = [session, ...state];
    await _saveSessions();
  }

  Future<void> updateSession(RunSession session) async {
    state = state.map((s) => s.id == session.id ? session : s).toList();
    await _saveSessions();
  }

  List<RunSession> getSessionsByDate(DateTime date) {
    return state.where((session) {
      return session.startTime.year == date.year &&
          session.startTime.month == date.month &&
          session.startTime.day == date.day;
    }).toList();
  }

  List<DateTime> getDatesWithRuns() {
    return state.map((session) {
      final date = session.startTime;
      return DateTime(date.year, date.month, date.day);
    }).toSet().toList();
  }
}

// Current active run provider
final activeRunProvider = StateNotifierProvider<ActiveRunNotifier, RunSession?>((ref) {
  return ActiveRunNotifier();
});

class ActiveRunNotifier extends StateNotifier<RunSession?> {
  ActiveRunNotifier() : super(null);

  void startRun() {
    state = RunSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      distanceKm: 0,
      durationMinutes: 0,
      caloriesBurned: 0,
      averagePaceMinPerKm: 0,
    );
  }

  void updateRun({
    double? distanceKm,
    int? durationMinutes,
    int? caloriesBurned,
    double? averagePaceMinPerKm,
    List<LocationPoint>? route,
  }) {
    if (state != null) {
      state = state!.copyWith(
        distanceKm: distanceKm ?? state!.distanceKm,
        durationMinutes: durationMinutes ?? state!.durationMinutes,
        caloriesBurned: caloriesBurned ?? state!.caloriesBurned,
        averagePaceMinPerKm: averagePaceMinPerKm ?? state!.averagePaceMinPerKm,
        route: route ?? state!.route,
      );
    }
  }

  void completeRun({String? selfieImagePath}) {
    if (state != null) {
      state = state!.copyWith(
        endTime: DateTime.now(),
        isCompleted: true,
        selfieImagePath: selfieImagePath,
      );
    }
  }

  void cancelRun() {
    state = null;
  }
}

// Marathon events provider
final marathonEventsProvider = StateNotifierProvider<MarathonEventsNotifier, List<MarathonEvent>>((ref) {
  return MarathonEventsNotifier();
});

class MarathonEventsNotifier extends StateNotifier<List<MarathonEvent>> {
  MarathonEventsNotifier() : super([]) {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('marathon_events');
    
    if (eventsJson != null) {
      final List<dynamic> decoded = json.decode(eventsJson);
      state = decoded.map((e) => MarathonEvent.fromJson(e)).toList();
      // Sort by date (upcoming first)
      state.sort((a, b) => a.date.compareTo(b.date));
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(state.map((e) => e.toJson()).toList());
    await prefs.setString('marathon_events', encoded);
  }

  Future<void> addEvent(MarathonEvent event) async {
    state = [...state, event];
    state.sort((a, b) => a.date.compareTo(b.date));
    await _saveEvents();
  }

  Future<void> updateEvent(MarathonEvent event) async {
    state = state.map((e) => e.id == event.id ? event : e).toList();
    state.sort((a, b) => a.date.compareTo(b.date));
    await _saveEvents();
  }

  Future<void> deleteEvent(String eventId) async {
    state = state.where((e) => e.id != eventId).toList();
    await _saveEvents();
  }

  Future<void> toggleReminder(String eventId) async {
    state = state.map((e) {
      if (e.id == eventId) {
        return e.copyWith(isReminded: !e.isReminded);
      }
      return e;
    }).toList();
    await _saveEvents();
  }

  List<MarathonEvent> get upcomingEvents {
    return state.where((e) => e.isUpcoming).toList();
  }

  List<MarathonEvent> get pastEvents {
    return state.where((e) => !e.isUpcoming).toList();
  }
}

// Weekly goals provider
final weeklyGoalsProvider = StateNotifierProvider<WeeklyGoalsNotifier, WeeklyGoals>((ref) {
  return WeeklyGoalsNotifier();
});

class WeeklyGoalsNotifier extends StateNotifier<WeeklyGoals> {
  WeeklyGoalsNotifier() : super(WeeklyGoals()) {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString('weekly_goals');
    
    if (goalsJson != null) {
      state = WeeklyGoals.fromJson(json.decode(goalsJson));
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weekly_goals', json.encode(state.toJson()));
  }

  Future<void> updateGoals(WeeklyGoals goals) async {
    state = goals;
    await _saveGoals();
  }
}
