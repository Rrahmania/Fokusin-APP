import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() =>
      _ProfilScreenState();
}

class _ProfilScreenState
    extends State<ProfilScreen> {

  String name = 'Rahmania Utami';

  String email = 'rahmania@gmail.com';

  int pomodoros = 25;

  int streak = 7;

  int xp = 850;

  void editProfile() {
    final nameController =
    TextEditingController(text: name);

    final emailController =
    TextEditingController(text: email);

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Profile',
          ),

          content: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              TextField(
                controller:
                nameController,

                decoration:
                const InputDecoration(
                  labelText: 'Name',
                  prefixIcon:
                  Icon(Icons.person),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              TextField(
                controller:
                emailController,

                decoration:
                const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                  Icon(Icons.email),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child:
              const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  name =
                      nameController.text;

                  email =
                      emailController.text;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Profile berhasil diperbarui ✓',
                    ),
                  ),
                );
              },

              child:
              const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void logout() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),

          content: const Text(
            'Apakah kamu yakin ingin keluar?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child:
              const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logout berhasil.',
                    ),
                  ),
                );
              },

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red,
              ),

              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5FAF9),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(20),

          child: Column(
            children: [
              // =================================================
              // PROFILE HEADER
              // =================================================

              Container(
                width: double.infinity,

                padding:
                const EdgeInsets.all(25),

                decoration:
                BoxDecoration(
                  gradient:
                  const LinearGradient(
                    colors: [
                      AppTheme.primaryTeal,
                      AppTheme.darkTeal,
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    25,
                  ),
                ),

                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,

                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,

                        shape:
                        BoxShape.circle,
                      ),

                      child: Center(
                        child: Text(
                          name.isNotEmpty
                              ? name[0]
                              .toUpperCase()
                              : 'U',

                          style:
                          const TextStyle(
                            fontSize: 36,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            AppTheme.darkTeal,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 15),

                    Text(
                      name,

                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 21,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 5),

                    Text(
                      email,

                      style:
                      const TextStyle(
                        color:
                        Colors.white70,
                      ),
                    ),

                    const SizedBox(
                        height: 18),

                    OutlinedButton.icon(
                      onPressed:
                      editProfile,

                      icon:
                      const Icon(
                        Icons.edit,
                      ),

                      label:
                      const Text(
                        'Edit Profile',
                      ),

                      style:
                      OutlinedButton.styleFrom(
                        foregroundColor:
                        Colors.white,

                        side:
                        const BorderSide(
                          color:
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 25),

              // =================================================
              // STATISTICS
              // =================================================

              Row(
                children: [
                  Expanded(
                    child:
                    _ProfileStat(
                      value:
                      '$pomodoros',
                      label:
                      'Pomodoros',
                      icon:
                      Icons.timer,
                    ),
                  ),

                  const SizedBox(
                      width: 10),

                  Expanded(
                    child:
                    _ProfileStat(
                      value:
                      '$streak',
                      label:
                      'Day Streak',
                      icon:
                      Icons
                          .local_fire_department,
                    ),
                  ),

                  const SizedBox(
                      width: 10),

                  Expanded(
                    child:
                    _ProfileStat(
                      value:
                      '$xp',
                      label:
                      'XP',
                      icon:
                      Icons.star,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 25),

              // =================================================
              // SETTINGS
              // =================================================

              const Align(
                alignment:
                Alignment.centerLeft,

                child: Text(
                  'Settings',
                  style:
                  TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                  height: 12),

              _SettingTile(
                icon:
                Icons.notifications_none,
                title:
                'Notifications',
                onTap: () {},
              ),

              _SettingTile(
                icon:
                Icons.volume_up_outlined,
                title:
                'Focus Sounds',
                onTap: () {},
              ),

              _SettingTile(
                icon:
                Icons.dark_mode_outlined,
                title:
                'Appearance',
                onTap: () {},
              ),

              _SettingTile(
                icon:
                Icons.help_outline,
                title:
                'Help & Support',
                onTap: () {},
              ),

              const SizedBox(
                  height: 15),

              // =================================================
              // LOGOUT
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: OutlinedButton.icon(
                  onPressed:
                  logout,

                  icon:
                  const Icon(
                    Icons.logout,
                  ),

                  label:
                  const Text(
                    'Logout',
                  ),

                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    Colors.red,

                    side:
                    const BorderSide(
                      color:
                      Colors.red,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
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


// ===============================================================
// PROFILE STAT
// ===============================================================

class _ProfileStat
    extends StatelessWidget {

  final String value;

  final String label;

  final IconData icon;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 15,
      ),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          17,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,

            color:
            AppTheme.primaryTeal,
          ),

          const SizedBox(
              height: 7),

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
              height: 3),

          Text(
            label,

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
// SETTING TILE
// ===============================================================

class _SettingTile
    extends StatelessWidget {

  final IconData icon;

  final String title;

  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          17,
        ),
      ),

      child: ListTile(
        onTap: onTap,

        leading: Container(
          padding:
          const EdgeInsets.all(
            9,
          ),

          decoration:
          BoxDecoration(
            color:
            AppTheme.lightTeal,

            borderRadius:
            BorderRadius.circular(
              11,
            ),
          ),

          child: Icon(
            icon,

            color:
            AppTheme.darkTeal,
          ),
        ),

        title: Text(
          title,

          style:
          const TextStyle(
            fontWeight:
            FontWeight.w600,
          ),
        ),

        trailing:
        const Icon(
          Icons.chevron_right,
          color:
          AppTheme.textGrey,
        ),
      ),
    );
  }
}