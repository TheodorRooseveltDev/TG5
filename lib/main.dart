import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'shared/providers/app_providers.dart';
import 'shared/widgets/splash_loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: RabbitRunTrackerApp()));
}

class RabbitRunTrackerApp extends ConsumerWidget {
  const RabbitRunTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Rabbit RunTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MainNavigationScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

// Splash screen that shows first
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Navigate to app initializer
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppInitializer()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashLoadingScreen();
  }
}

// App initializer to check onboarding status
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    // Show loading while profile is being loaded
    if (userProfile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBFFF00)),
          ),
        ),
      );
    }

    // Check if user has completed onboarding (changed from default name)
    if (userProfile.name == 'Rabbit Runner') {
      return const OnboardingScreen();
    }

    return const MainNavigationScreen();
  }
}


