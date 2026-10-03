import 'package:flutter/material.dart';

import '../main.dart';
import '../theme/app_theme.dart';

import '../screens/home_screen.dart';
import '../screens/timer_screen.dart';
import '../screens/gang_screen.dart';
import '../screens/challenge_screen.dart';
import '../screens/profil_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({
    super.key,
  });

  @override
  State<BottomNav> createState() =>
      _BottomNavState();
}

class _BottomNavState
    extends State<BottomNav> {

  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    TimerScreen(),
    GangScreen(),
    ChallengeScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar:
      NavigationBar(

        selectedIndex:
        currentIndex,

        onDestinationSelected:
            (index) {

          setState(() {
            currentIndex = index;
          });

        },

        backgroundColor:
        Colors.white,

        indicatorColor:
        AppTheme.lightTeal,

        destinations: const [

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
              color:
              AppTheme.darkTeal,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.timer_outlined,
            ),
            selectedIcon: Icon(
              Icons.timer,
              color:
              AppTheme.darkTeal,
            ),
            label: 'Timer',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.groups_outlined,
            ),
            selectedIcon: Icon(
              Icons.groups,
              color:
              AppTheme.darkTeal,
            ),
            label: 'Gang',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.emoji_events_outlined,
            ),
            selectedIcon: Icon(
              Icons.emoji_events,
              color:
              AppTheme.darkTeal,
            ),
            label: 'Challenge',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
              color:
              AppTheme.darkTeal,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}