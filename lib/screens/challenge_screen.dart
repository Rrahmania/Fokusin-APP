import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() =>
      _ChallengeScreenState();
}

class _ChallengeScreenState
    extends State<ChallengeScreen> {

  final List<Map<String, dynamic>> challenges = [
    {
      'title': 'Pomodoro Starter',
      'description': 'Complete 3 Pomodoro sessions.',
      'reward': 50,
      'progress': 2,
      'target': 3,
      'icon': Icons.timer,
      'completed': false,
    },

    {
      'title': 'Focus Master',
      'description': 'Focus for 2 hours today.',
      'reward': 100,
      'progress': 1,
      'target': 2,
      'icon': Icons.psychology,
      'completed': false,
    },

    {
      'title': 'Early Bird',
      'description': 'Complete a Pomodoro before 10 AM.',
      'reward': 75,
      'progress': 1,
      'target': 1,
      'icon': Icons.wb_sunny,
      'completed': true,
    },

    {
      'title': 'Consistency',
      'description': 'Keep your streak for 7 days.',
      'reward': 200,
      'progress': 5,
      'target': 7,
      'icon': Icons.local_fire_department,
      'completed': false,
    },
  ];

  void completeChallenge(int index) {
    setState(() {
      challenges[index]['completed'] = true;
      challenges[index]['progress'] =
      challenges[index]['target'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Challenge completed! +${challenges[index]['reward']} XP 🎉',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5FAF9),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Text(
                'Challenges',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTeal,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Complete challenges and earn XP.',
                style: TextStyle(
                  color: AppTheme.textGrey,
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // XP CARD
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,

                  borderRadius:
                  BorderRadius.circular(22),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,

                      decoration:
                      BoxDecoration(
                        color: Colors.white24,
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                      ),

                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Your XP',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          '250 XP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Available Challenges',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...List.generate(
                challenges.length,
                    (index) {
                  final challenge =
                  challenges[index];

                  final progress =
                      challenge['progress'] /
                          challenge['target'];

                  return Container(
                    margin:
                    const EdgeInsets.only(
                      bottom: 14,
                    ),

                    padding:
                    const EdgeInsets.all(17),

                    decoration:
                    BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,

                              decoration:
                              BoxDecoration(
                                color:
                                AppTheme.lightTeal,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  14,
                                ),
                              ),

                              child: Icon(
                                challenge['icon'],
                                color:
                                AppTheme.darkTeal,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [
                                  Text(
                                    challenge[
                                    'title'],

                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Text(
                                    challenge[
                                    'description'],

                                    style:
                                    const TextStyle(
                                      color:
                                      AppTheme
                                          .textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              '+${challenge['reward']} XP',

                              style:
                              const TextStyle(
                                color:
                                AppTheme
                                    .primaryTeal,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child:
                              ClipRRect(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  10,
                                ),

                                child:
                                LinearProgressIndicator(
                                  value: progress
                                      .clamp(
                                    0.0,
                                    1.0,
                                  ),

                                  minHeight: 8,

                                  backgroundColor:
                                  AppTheme
                                      .lightTeal,

                                  color:
                                  AppTheme
                                      .primaryTeal,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Text(
                              '${challenge['progress']}/${challenge['target']}',

                              style:
                              const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (challenge['completed'])
                          const Row(
                            children: [
                              Icon(
                                Icons
                                    .check_circle,
                                color:
                                Colors.green,
                                size: 18,
                              ),

                              SizedBox(width: 6),

                              Text(
                                'Completed',
                                style:
                                TextStyle(
                                  color:
                                  Colors.green,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        else
                          SizedBox(
                            width: double.infinity,

                            height: 42,

                            child:
                            ElevatedButton(
                              onPressed:
                              challenge[
                              'progress'] >=
                                  challenge[
                                  'target']
                                  ? () =>
                                  completeChallenge(
                                    index,
                                  )
                                  : null,

                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                AppTheme
                                    .primaryTeal,

                                foregroundColor:
                                Colors.white,

                                elevation: 0,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),
                              ),

                              child: const Text(
                                'Complete',
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}