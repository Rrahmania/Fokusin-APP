import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GangScreen extends StatefulWidget {
  const GangScreen({super.key});

  @override
  State<GangScreen> createState() => _GangScreenState();
}

class _GangScreenState extends State<GangScreen> {
  bool isJoined = false;

  final List<Map<String, dynamic>> friends = [
    {
      'name': 'Andina',
      'initial': 'A',
      'pomodoro': 6,
      'online': true,
    },
    {
      'name': 'Fathur',
      'initial': 'F',
      'pomodoro': 4,
      'online': true,
    },
    {
      'name': 'Rahma',
      'initial': 'R',
      'pomodoro': 8,
      'online': false,
    },
  ];

  void joinGang() {
    setState(() {
      isJoined = !isJoined;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isJoined
              ? 'Kamu bergabung ke Focus Gang 🎉'
              : 'Kamu keluar dari Focus Gang.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Pomodoro Gang',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTeal,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Focus together with your friends.',
                style: TextStyle(
                  color: AppTheme.textGrey,
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // GANG CARD
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryTeal,
                      AppTheme.darkTeal,
                    ],
                  ),

                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                          const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius:
                            BorderRadius.circular(15),
                          ),

                          child: const Icon(
                            Icons.groups,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Focus Squad',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                '4 members',
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Keep each other motivated and complete your Pomodoro sessions together.',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: ElevatedButton(
                        onPressed: joinGang,

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.white,

                          foregroundColor:
                          AppTheme.darkTeal,

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),

                        child: Text(
                          isJoined
                              ? 'Leave Gang'
                              : 'Join Gang',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // MEMBERS
              // =================================================

              const Text(
                'Gang Members',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...friends.map(
                    (friend) {
                  return Container(
                    margin:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),

                    padding:
                    const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(17),
                    ),

                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 23,

                              backgroundColor:
                              AppTheme.lightTeal,

                              child: Text(
                                friend['initial'],
                                style:
                                const TextStyle(
                                  color:
                                  AppTheme.darkTeal,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),

                            if (friend['online'])
                              Positioned(
                                right: 0,
                                bottom: 0,

                                child: Container(
                                  width: 12,
                                  height: 12,

                                  decoration:
                                  BoxDecoration(
                                    color:
                                    Colors.green,
                                    shape:
                                    BoxShape.circle,
                                    border:
                                    Border.all(
                                      color:
                                      Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              Text(
                                friend['name'],
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${friend['pomodoro']} Pomodoros completed',
                                style:
                                const TextStyle(
                                  color:
                                  AppTheme.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // =================================================
              // INVITE FRIEND
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            'Invite Friend',
                          ),

                          content: const Text(
                            'Fitur invite teman akan tersedia pada tahap berikutnya.',
                          ),

                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },

                              child:
                              const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },

                  icon: const Icon(
                    Icons.person_add,
                  ),

                  label: const Text(
                    'Invite Friend',
                  ),

                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    AppTheme.primaryTeal,

                    side: const BorderSide(
                      color:
                      AppTheme.primaryTeal,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
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