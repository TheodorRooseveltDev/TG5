import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class GPSTrackingService {
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  double _totalDistanceMeters = 0.0;
  
  final _distanceController = StreamController<double>.broadcast();
  final _speedController = StreamController<double>.broadcast();
  final _paceController = StreamController<String>.broadcast();
  
  Stream<double> get distanceStream => _distanceController.stream;
  Stream<double> get speedStream => _speedController.stream;
  Stream<String> get paceStream => _paceController.stream;
  
  double get totalDistanceKm => _totalDistanceMeters / 1000;
  
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  // Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }
  
  // Request location permission (triggers iOS native dialog)
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
  
  // Start tracking
  Future<bool> startTracking() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return false;
      }
      
      // Check permission
      LocationPermission permission = await checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        return false;
      }
      
      // Reset tracking data
      _lastPosition = null;
      _totalDistanceMeters = 0.0;
      
      // Get initial position
      _lastPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      
      // Start listening to position updates
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Update every 5 meters
      );
      
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _updateDistance(position);
      });
      
      debugPrint('GPS tracking started');
      return true;
    } catch (e) {
      debugPrint('Error starting GPS tracking: $e');
      return false;
    }
  }
  
  // Update distance calculation
  void _updateDistance(Position newPosition) {
    if (_lastPosition != null) {
      // Calculate distance between last position and new position
      double distanceInMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
      
      // Only add if movement is significant (more than 3 meters)
      // This helps filter out GPS noise when standing still
      if (distanceInMeters > 3) {
        _totalDistanceMeters += distanceInMeters;
        _distanceController.add(totalDistanceKm);
        
        // Calculate speed in km/h from GPS speed (m/s to km/h)
        double speedKmh = newPosition.speed * 3.6;
        _speedController.add(speedKmh);
        
        // Calculate pace (min/km) from speed
        // Pace = 60 / speed (when speed is in km/h)
        String pace = _calculatePace(speedKmh);
        _paceController.add(pace);
        
        debugPrint('Distance: ${totalDistanceKm.toStringAsFixed(2)} km, Speed: ${speedKmh.toStringAsFixed(1)} km/h, Pace: $pace');
      }
    }
    
    _lastPosition = newPosition;
  }
  
  // Calculate pace from speed (returns formatted string like "5:30")
  String _calculatePace(double speedKmh) {
    // If speed is too slow or zero, return default pace
    if (speedKmh < 0.5) {
      return "--:--";
    }
    
    // Calculate minutes per kilometer
    double paceMinPerKm = 60 / speedKmh;
    
    // If pace is unrealistically slow (walking or standing), cap it
    if (paceMinPerKm > 20) {
      return "--:--";
    }
    
    // Convert to minutes and seconds
    int minutes = paceMinPerKm.floor();
    int seconds = ((paceMinPerKm - minutes) * 60).round();
    
    // Format as "M:SS"
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Pause tracking (keep data, stop updates)
  void pauseTracking() {
    _positionStream?.pause();
    debugPrint('GPS tracking paused');
  }
  
  // Resume tracking
  void resumeTracking() {
    _positionStream?.resume();
    debugPrint('GPS tracking resumed');
  }
  
  // Stop tracking and cleanup
  Future<void> stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    debugPrint('GPS tracking stopped. Total distance: ${totalDistanceKm.toStringAsFixed(2)} km');
  }
  
  // Get current position once
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }
  
  // Open app settings (for when permission is denied forever)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
  
  // Cleanup
  void dispose() {
    _positionStream?.cancel();
    _distanceController.close();
    _speedController.close();
    _paceController.close();
  }
}
