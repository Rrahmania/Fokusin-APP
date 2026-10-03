import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/music_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // =====================================================
              // HEADER
              // =====================================================

              Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: const [

                        Text(
                          'Good Morning 👋',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGrey,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Rahmania',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTeal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),

                    child: const Center(
                      child: Text(
                        'R',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =====================================================
              // MAIN FOCUS CARD
              // =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                    colors: [
                      AppTheme.primaryTeal,
                      AppTheme.darkTeal,
                    ],
                  ),

                  borderRadius: BorderRadius.circular(25),

                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal
                          .withOpacity(0.20),

                      blurRadius: 20,

                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        Container(
                          padding:
                          const EdgeInsets.all(10),

                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white24,

                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),

                          child:
                          const Icon(
                            Icons.timer,
                            color:
                            Colors.white,
                            size: 28,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Expanded(
                          child: Text(
                            'Ready to focus?',
                            style:
                            TextStyle(
                              color:
                              Colors.white,

                              fontSize: 20,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'Start a Pomodoro session and get things done.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton.icon(
                        onPressed: () {

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) =>
                              const _TimerPage(),
                            ),
                          );

                        },

                        icon: const Icon(
                          Icons.play_arrow,
                        ),

                        label: const Text(
                          'Start Focus',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.white,

                          foregroundColor:
                          AppTheme.darkTeal,

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // STATISTICS
              // =====================================================

              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer,
                      value: '8',
                      title: 'Pomodoros',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _StatCard(
                      icon:
                      Icons.local_fire_department,
                      value: '5',
                      title: 'Day Streak',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _StatCard(
                      icon: Icons.star,
                      value: '250',
                      title: 'XP',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =====================================================
              // TODAY'S FOCUS
              // =====================================================

              Row(
                children: [

                  const Expanded(
                    child: Text(
                      "Today's Focus",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                          const _TimerPage(),
                        ),
                      );

                    },

                    child: const Text(
                      'Start',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                padding:
                const EdgeInsets.all(18),

                decoration:
                BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                  border: Border.all(
                    color:
                    AppTheme.lightTeal,
                  ),
                ),

                child: Row(
                  children: [

                    Container(
                      width: 50,
                      height: 50,

                      decoration:
                      BoxDecoration(
                        color:
                        AppTheme.lightTeal,

                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),

                      child:
                      const Icon(
                        Icons.menu_book,
                        color:
                        AppTheme.darkTeal,
                      ),
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Text(
                            'Study Session',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight.bold,

                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            '25 minutes • 1 Pomodoro',
                            style:
                            TextStyle(
                              color:
                              AppTheme.textGrey,

                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                      AppTheme.textGrey,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // AI RECOMMENDATION
              // =====================================================

              const Text(
                'AI Recommendation',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding:
                const EdgeInsets.all(18),

                decoration:
                BoxDecoration(
                  color:
                  AppTheme.lightTeal,

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Container(
                      padding:
                      const EdgeInsets.all(11),

                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,

                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),

                      child:
                      const Icon(
                        Icons.auto_awesome,
                        color:
                        AppTheme.primaryTeal,
                      ),
                    ),

                    const SizedBox(
                      width: 13,
                    ),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Text(
                            'What should you learn today?',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight.bold,

                              color:
                              AppTheme.darkTeal,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Try learning Flutter UI for 25 minutes. You have been focusing well on programming lately.',
                            style:
                            TextStyle(
                              fontSize: 13,

                              height: 1.5,

                              color:
                              AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // ACTIVITY
              // =====================================================

              const Text(
                'Focus Activity',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.menu_book,
                      title: 'Study',
                      subtitle: 'Learn something',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.work_outline,
                      title: 'Work',
                      subtitle: 'Get things done',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.fitness_center,
                      title: 'Exercise',
                      subtitle: 'Stay active',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.auto_stories,
                      title: 'Reading',
                      subtitle: 'Read & relax',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =====================================================
              // MUSIC
              // =====================================================

              const Text(
                'Relax & Focus',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              MusicCard(),

              const SizedBox(height: 25),

              // =====================================================
              // CHALLENGE
              // =====================================================

              Row(
                children: [

                  const Expanded(
                    child: Text(
                      'Today\'s Challenge',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},

                    child: const Text(
                      'See All',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                padding:
                const EdgeInsets.all(18),

                decoration:
                BoxDecoration(
                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        Container(
                          padding:
                          const EdgeInsets.all(
                            10,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFFFFF4D6,
                            ),

                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),

                          child:
                          const Icon(
                            Icons.emoji_events,
                            color:
                            Colors.orange,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                'Complete 3 Pomodoros',
                                style:
                                TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                'Reward: +50 XP',
                                style:
                                TextStyle(
                                  color:
                                  AppTheme.textGrey,

                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Text(
                          '2/3',
                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight.bold,

                            color:
                            AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),

                      child:
                      const LinearProgressIndicator(
                        value: 0.66,

                        minHeight: 8,

                        backgroundColor:
                        AppTheme.lightTeal,

                        color:
                        AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // TIPS
              // =====================================================

              const Text(
                'Tips & Tricks',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding:
                const EdgeInsets.all(18),

                decoration:
                BoxDecoration(
                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Icon(
                      Icons.lightbulb_outline,
                      color:
                      Colors.amber,
                      size: 28,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    const Expanded(
                      child: Text(
                        'Letakkan HP dalam mode silent selama Pomodoro agar tidak mudah terdistraksi.',
                        style:
                        TextStyle(
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ===============================================================
// STAT CARD
// ===============================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color:
            AppTheme.primaryTeal,
            size: 25,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            value,

            style:
            const TextStyle(
              fontSize: 20,

              fontWeight:
              FontWeight.bold,

              color:
              AppTheme.darkTeal,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            title,

            textAlign:
            TextAlign.center,

            style:
            const TextStyle(
              fontSize: 10,

              color:
              AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}


// ===============================================================
// ACTIVITY CARD
// ===============================================================

class _ActivityCard
    extends StatelessWidget {

  final IconData icon;
  final String title;
  final String subtitle;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      borderRadius:
      BorderRadius.circular(
        18,
      ),

      onTap: () {

        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) =>
            const _TimerPage(),
          ),
        );

      },

      child: Container(
        padding:
        const EdgeInsets.all(
          16,
        ),

        decoration:
        BoxDecoration(
          color:
          Colors.white,

          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Container(
              padding:
              const EdgeInsets.all(
                10,
              ),

              decoration:
              BoxDecoration(
                color:
                AppTheme.lightTeal,

                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),

              child:
              Icon(
                icon,
                color:
                AppTheme.darkTeal,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              title,

              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,

                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              subtitle,

              style:
              const TextStyle(
                color:
                AppTheme.textGrey,

                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ===============================================================
// TIMER PAGE SEMENTARA
// ===============================================================

class _TimerPage
    extends StatefulWidget {

  const _TimerPage();

  @override
  State<_TimerPage> createState() =>
      _TimerPageState();
}

class _TimerPageState
    extends State<_TimerPage> {

  int minutes = 25;

  int seconds = 0;

  bool running = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
          'Pomodoro Timer',
        ),
      ),

      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              const Text(
                'Focus Time',
                style:
                TextStyle(
                  fontSize: 18,
                  color:
                  AppTheme.textGrey,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                '${minutes.toString().padLeft(2, '0')}:'
                    '${seconds.toString().padLeft(2, '0')}',

                style:
                const TextStyle(
                  fontSize: 60,

                  fontWeight:
                  FontWeight.bold,

                  color:
                  AppTheme.darkTeal,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  ChoiceChip(
                    label:
                    const Text(
                      '15 min',
                    ),

                    selected:
                    minutes == 15,

                    onSelected: (_) {

                      setState(() {
                        minutes = 15;
                        seconds = 0;
                      });

                    },
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  ChoiceChip(
                    label:
                    const Text(
                      '25 min',
                    ),

                    selected:
                    minutes == 25,

                    onSelected: (_) {

                      setState(() {
                        minutes = 25;
                        seconds = 0;
                      });

                    },
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  ChoiceChip(
                    label:
                    const Text(
                      '45 min',
                    ),

                    selected:
                    minutes == 45,

                    onSelected: (_) {

                      setState(() {
                        minutes = 45;
                        seconds = 0;
                      });

                    },
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width: 180,
                height: 55,

                child:
                ElevatedButton.icon(
                  onPressed: () {

                    setState(() {
                      running =
                      !running;
                    });

                  },

                  icon:
                  Icon(
                    running
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),

                  label:
                  Text(
                    running
                        ? 'Pause'
                        : 'Start',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}