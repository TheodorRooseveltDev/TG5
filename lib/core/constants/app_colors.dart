import 'package:flutter/material.dart';

/// Premium dark theme colors for Rabbit RunTracker
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0A0A0A); // Pure black
  static const Color cardBackground = Color(0xFF1A1A1A); // Dark gray raised cards
  static const Color secondaryCard = Color(0xFF242424); // Nested elements

  // Primary accent
  static const Color neonGreen = Color(0xFFBFFF00); // Neon green for CTAs and highlights

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF); // Main text
  static const Color textSecondary = Color(0xFF9CA3AF); // Secondary labels

  // Progress ring colors
  static const Color orangeRing = Color(0xFFFF9500); // Distance
  static const Color cyanRing = Color(0xFF00D4FF); // Time
  static const Color yellowRing = Color(0xFFFFD60A); // Calories

  // Additional colors
  static const Color purpleGradientStart = Color(0xFFBF5AF2); // Training streak
  static const Color purpleGradientEnd = Color(0xFF9333EA);
  static const Color greenGradientStart = Color(0xFF10B981); // Nutrition streak
  static const Color greenGradientEnd = Color(0xFF059669);

  // Social
  static const Color likeRed = Color(0xFFEF4444);
  static const Color commentGray = Color(0xFF6B7280);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Navigation
  static const Color navInactive = Color(0xFF6B7280);
  static const Color navActive = neonGreen;

  // Shadow
  static const Color shadowColor = Color(0x4D000000); // Black 30% opacity
}
