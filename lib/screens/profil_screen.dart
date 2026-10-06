import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String name = 'User';
  String email = '-';
  int pomodoros = 0;
  int streak = 0;
  int xp = 0;

  bool darkMode = false;
  bool lockApp = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    AppTheme.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppTheme.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() => darkMode = AppTheme.isDarkMode);
  }

  Future<void> _loadSettings() async {
    final n = await StorageService.getCurrentUserName();
    final e = await StorageService.getCurrentUserEmail();
    final lock = await StorageService.loadLockApp();
    final total = await StorageService.loadTotalPomodoro();
    final s = await StorageService.loadStreak();
    final userXp = await StorageService.loadXp();

    if (!mounted) return;
    setState(() {
      name = n;
      email = e;
      lockApp = lock;
      pomodoros = total;
      streak = s;
      xp = userXp;
      darkMode = AppTheme.isDarkMode;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    AppTheme.setDarkMode(value);
    if (mounted) setState(() => darkMode = value);
  }

  Future<void> _toggleLockApp(bool value) async {
    setState(() => lockApp = value);
    await StorageService.saveLockApp(value);
  }

  // ============================================================
  // EDIT PROFILE DIALOG (FIXED)
  // ============================================================
  void editProfile() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit,
                        color: AppTheme.darkTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.txt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // NAME FIELD
              TextField(
                controller: nameController,
                style: TextStyle(color: AppTheme.txt),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),

              // EMAIL FIELD
              TextField(
                controller: emailController,
                style: TextStyle(color: AppTheme.txt),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 22),

              // TOMBOL SEJAJAR
              Row(
                children: [
                  // CANCEL
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.txt,
                          side: BorderSide(
                            color: AppTheme.txtGrey.withOpacity(0.4),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // SAVE
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          final newEmail = emailController.text.trim();

                          if (newName.isEmpty || newEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text('Nama dan email tidak boleh kosong'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          await StorageService.updateCurrentUserName(
                              newName);
                          await StorageService.updateCurrentUserEmail(
                              newEmail);

                          if (!mounted) return;
                          setState(() {
                            name = newName;
                            email = newEmail;
                          });
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile berhasil diperbarui ✓'),
                              backgroundColor: AppTheme.darkTeal,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG (FIXED)
  // ============================================================
  void logout() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON + TITLE
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout,
                        color: Colors.red, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.txt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // PESAN
              Text(
                'Apakah kamu yakin ingin keluar dari akun ini?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.txtGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              // TOMBOL SEJAJAR
              Row(
                children: [
                  // CANCEL
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.txt,
                          side: BorderSide(
                            color: AppTheme.txtGrey.withOpacity(0.4),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // LOGOUT
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          await StorageService.logout();
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ============ HEADER ============
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(email,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: editProfile,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ============ STATS ============
              Row(
                children: [
                  Expanded(
                    child: _ProfileStat(
                        value: '$pomodoros',
                        label: 'Pomodoros',
                        icon: Icons.timer),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ProfileStat(
                        value: '$streak',
                        label: 'Day Streak',
                        icon: Icons.local_fire_department),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ProfileStat(
                        value: '$xp', label: 'XP', icon: Icons.star),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // ============ SETTINGS ============
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Settings',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.txt)),
              ),
              const SizedBox(height: 12),

              _SettingSwitch(
                icon: darkMode ? Icons.dark_mode : Icons.light_mode,
                title: 'Dark Mode',
                subtitle: darkMode ? 'Aktif' : 'Nonaktif',
                value: darkMode,
                onChanged: _toggleDarkMode,
              ),
              _SettingSwitch(
                icon: Icons.lock_outline,
                title: 'Kunci Aplikasi',
                subtitle: 'Tidak bisa keluar saat timer berjalan',
                value: lockApp,
                onChanged: _toggleLockApp,
              ),
              _SettingTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () {},
              ),
              _SettingTile(
                icon: Icons.volume_up_outlined,
                title: 'Focus Sounds',
                onTap: () {},
              ),
              _SettingTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: 15),

              // ============ LOGOUT BUTTON ============
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
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

// ============================================================
// PROFILE STAT
// ============================================================
class _ProfileStat extends StatelessWidget {
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
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryTeal),
          const SizedBox(height: 7),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.txt)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(fontSize: 10, color: AppTheme.txtGrey)),
        ],
      ),
    );
  }
}

// ============================================================
// SETTING TILE
// ============================================================
class _SettingTile extends StatelessWidget {
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppTheme.lightTeal,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppTheme.darkTeal),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppTheme.txt)),
        trailing: Icon(Icons.chevron_right, color: AppTheme.txtGrey),
      ),
    );
  }
}

// ============================================================
// SETTING SWITCH (CUSTOM)
// ============================================================
class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.lightTeal,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppTheme.darkTeal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.txt)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.txtGrey)),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // CUSTOM SWITCH
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value
                    ? AppTheme.primaryTeal
                    : (AppTheme.isDarkMode
                    ? const Color(0xFF3A4A48)
                    : const Color(0xFFCFD8DC)),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: value
                      ? Colors.transparent
                      : (AppTheme.isDarkMode
                      ? const Color(0xFF546E7A)
                      : const Color(0xFFB0BEC5)),
                  width: 1.5,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment:
                value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}