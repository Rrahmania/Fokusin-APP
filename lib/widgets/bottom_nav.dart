import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/timer_screen.dart';
import '../screens/gang_screen.dart';
import '../screens/challenge_screen.dart';
import '../screens/profil_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  // 👇 Static notifier biar halaman lain bisa pindah tab
  static final ValueNotifier<int> navNotifier = ValueNotifier<int>(0);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = BottomNav.navNotifier.value;
    BottomNav.navNotifier.addListener(_onNavChanged);
  }

  @override
  void dispose() {
    BottomNav.navNotifier.removeListener(_onNavChanged);
    super.dispose();
  }

  void _onNavChanged() {
    if (mounted && currentIndex != BottomNav.navNotifier.value) {
      setState(() => currentIndex = BottomNav.navNotifier.value);
    }
  }

  Widget _getPage() {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const TimerScreen();
      case 2:
        return const GangScreen();
      case 3:
        return const ChallengeScreen();
      case 4:
        return const ProfilScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, dark, _) {
        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: _getPage(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              BottomNav.navNotifier.value = index;
              setState(() => currentIndex = index);
            },
            backgroundColor: AppTheme.card,
            indicatorColor: AppTheme.isDarkMode
                ? AppTheme.primaryTeal.withOpacity(0.25)
                : AppTheme.lightTeal,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.timer_outlined),
                selectedIcon: Icon(Icons.timer),
                label: 'Timer',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: 'Gang',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Challenge',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}