import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/challenge_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Sesi aktif
  int selectedMinutes = 25;
  int selectedSeconds = 0;
  int remainingSeconds = 25 * 60;

  Timer? timer;
  bool isRunning = false;
  bool lockApp = false;

  // Preset aktif (untuk highlight): 15, 25, 45, atau null untuk custom
  int? activePreset = 25;

  // Daftar custom preset tersimpan
  List<Map<String, dynamic>> customPresets = [];
  // Index preset yang sedang aktif (-1 = tidak ada)
  int activeCustomIndex = -1;

  // Aktivitas yang dipilih sebelum sesi dimulai
  String selectedActivity = 'Belajar';
  final List<Map<String, dynamic>> activities = [
    {'name': 'Belajar', 'icon': Icons.menu_book_rounded},
    {'name': 'Coding', 'icon': Icons.code_rounded},
    {'name': 'Mengerjakan Tugas', 'icon': Icons.assignment_rounded},
    {'name': 'Bekerja', 'icon': Icons.work_outline_rounded},
    {'name': 'Membaca', 'icon': Icons.auto_stories_rounded},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_rounded},
  ];

  // Pilihan musik hanya sebagai tampilan UI, belum memutar audio.
  String selectedMusic = 'Lo-fi Focus';
  final List<Map<String, dynamic>> musicOptions = [
    {
      'name': 'Lo-fi Focus',
      'subtitle': 'Musik latar untuk fokus',
      'icon': Icons.headphones_rounded,
    },
    {
      'name': 'Calm Piano',
      'subtitle': 'Musik instrumental yang tenang',
      'icon': Icons.piano_rounded,
    },
    {
      'name': 'Ambient',
      'subtitle': 'Musik latar santai',
      'icon': Icons.spa_rounded,
    },
    {
      'name': 'Tanpa Musik',
      'subtitle': 'Fokus dalam keheningan',
      'icon': Icons.volume_off_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
    AppTheme.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    timer?.cancel();
    AppTheme.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadAll() async {
    final lock = await StorageService.loadLockApp();
    final presets = await StorageService.loadCustomPresets();
    if (!mounted) return;
    setState(() {
      lockApp = lock;
      customPresets = presets;
    });
  }

  void _selectMusic(Map<String, dynamic> music) {
    setState(() {
      selectedMusic = music['name'] as String;
    });
  }

  // Pilih preset 15/25/45
  void selectPreset(int minutes) {
    timer?.cancel();
    setState(() {
      selectedMinutes = minutes;
      selectedSeconds = 0;
      remainingSeconds = minutes * 60;
      isRunning = false;
      activePreset = minutes;
      activeCustomIndex = -1;
    });
  }

  // Pilih custom preset dari daftar
  void selectCustomPreset(int index) {
    final p = customPresets[index];
    final m = p['minutes'] as int;
    final s = p['seconds'] as int;

    // Jika preset dibuat untuk aktivitas tertentu, aktifkan aktivitas itu juga.
    final savedLabel = p['label'] as String? ?? '';
    final activityFromPreset = savedLabel.contains(' • ')
        ? savedLabel.split(' • ').first
        : null;
    timer?.cancel();
    setState(() {
      selectedMinutes = m;
      selectedSeconds = s;
      remainingSeconds = m * 60 + s;
      isRunning = false;
      activePreset = null;
      activeCustomIndex = index;
      if (activityFromPreset != null &&
          activities.any((a) => a['name'] == activityFromPreset)) {
        selectedActivity = activityFromPreset;
      }
    });
  }

  // Hapus preset
  Future<void> _deleteCustomPreset(int index) async {
    final p = customPresets[index];
    final m = p['minutes'] as int;
    final s = p['seconds'] as int;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus preset?'),
        content: Text('Hapus "${_formatLabel(m, s)}" dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await StorageService.deleteCustomPreset(m, s);
    if (!mounted) return;
    setState(() {
      if (activeCustomIndex == index) {
        activeCustomIndex = -1;
      } else if (activeCustomIndex > index) {
        activeCustomIndex--;
      }
      customPresets.removeAt(index);
    });
  }

  String _formatLabel(int minutes, int seconds) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) {
      if (m == 0 && seconds == 0) return '$h jam';
      if (seconds == 0) return '$h jam $m mnt';
      return '$h jam $m mnt $seconds dtk';
    }
    if (seconds > 0) return '$m mnt $seconds dtk';
    return '$m mnt';
  }

  // ==========================================================
  // CUSTOM TIME PICKER
  // ==========================================================
  Future<void> _openCustomTimeDialog() async {
    int tempHours = selectedMinutes ~/ 60;
    int tempMinutes = selectedMinutes % 60;
    int tempSeconds = selectedSeconds;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          height: 420,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.txtGrey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Atur Waktu',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.txt)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Max 3 jam',
                          style: TextStyle(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Scroll untuk atur jam, menit & detik',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.txtGrey)),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: AppTheme.isDarkMode
                        ? Brightness.dark
                        : Brightness.light,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: AppTheme.txt,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hms,
                    initialTimerDuration: Duration(
                      hours: tempHours,
                      minutes: tempMinutes,
                      seconds: tempSeconds,
                    ),
                    minuteInterval: 1,
                    secondInterval: 1,
                    alignment: Alignment.center,
                    backgroundColor: Colors.transparent,
                    onTimerDurationChanged: (Duration d) {
                      int totalMin = d.inHours * 60 + d.inMinutes % 60;
                      if (totalMin > 180) {
                        tempHours = 3;
                        tempMinutes = 0;
                        tempSeconds = 0;
                        return;
                      }
                      tempHours = d.inHours;
                      tempMinutes = d.inMinutes % 60;
                      tempSeconds = d.inSeconds % 60;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.txt,
                            side: BorderSide(
                                color: AppTheme.txtGrey.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Simpan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      final totalSeconds =
          tempHours * 3600 + tempMinutes * 60 + tempSeconds;
      if (totalSeconds < 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Minimal 1 detik'),
            backgroundColor: AppTheme.darkTeal,
          ),
        );
        return;
      }

      final totalMinutes = tempHours * 60 + tempMinutes;

      // Simpan ke daftar preset
      await StorageService.saveCustomPreset(
        minutes: totalMinutes,
        seconds: tempSeconds,
        // Nama preset menyimpan aktivitas agar preset mudah dikenali.
        label: '$selectedActivity • ${_formatLabel(totalMinutes, tempSeconds)}',
      );

      // Reload presets
      final presets = await StorageService.loadCustomPresets();

      int newIndex = presets.indexWhere((p) =>
      p['minutes'] == totalMinutes && p['seconds'] == tempSeconds);

      timer?.cancel();
      if (!mounted) return;
      setState(() {
        customPresets = presets;
        selectedMinutes = totalMinutes;
        selectedSeconds = tempSeconds;
        remainingSeconds = totalSeconds;
        isRunning = false;
        activePreset = null;
        activeCustomIndex = newIndex;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Preset disimpan: $selectedActivity • ${_formatLabel(totalMinutes, tempSeconds)} ✓'),
          backgroundColor: AppTheme.darkTeal,
        ),
      );
    }
  }

  void startTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
      return;
    }

    setState(() => isRunning = true);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingSeconds <= 0) {
        timer.cancel();
        setState(() => isRunning = false);

        await StorageService.recordPomodoroCompleted();
        final result = await ChallengeService.evaluate();

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$selectedActivity selesai! 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Great job! Kamu berhasil menyelesaikan sesi $selectedActivity.'),
                if (result.xpGained > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('+${result.xpGained} XP',
                            style: const TextStyle(
                                color: AppTheme.primaryTeal,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        ...result.newlyCompleted.map((c) => Text(
                            '🏆 ${c.title}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryTeal))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() => remainingSeconds--);
    });
  }

  Future<void> _confirmEndSession() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.favorite_rounded,
            color: AppTheme.primaryTeal, size: 34),
        title: const Text('Yakin ingin menyerah?'),
        content: Text(
          'Sesi $selectedActivity masih berjalan. Kamu sudah meluangkan waktu untuk fokus—mau lanjut sedikit lagi?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: const BorderSide(color: AppTheme.primaryTeal),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Tidak, lanjut fokus 💪'),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Ya, akhiri sesi'),
            ),
          ),
        ],
      ),
    );

    if (shouldEnd != true || !mounted) return;
    timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = selectedMinutes * 60 + selectedSeconds;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesi fokus diakhiri. Coba lagi kapan saja!')),
    );
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = selectedMinutes * 60 + selectedSeconds;
      isRunning = false;
    });
  }

  String get timerText {
    final h = remainingSeconds ~/ 3600;
    final m = (remainingSeconds % 3600) ~/ 60;
    final s = remainingSeconds % 60;

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = (screenWidth * 0.65).clamp(200.0, 280.0);

    return WillPopScope(
      onWillPop: () async {
        if (isRunning && lockApp) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Timer Sedang Berjalan ⏱️'),
              content: const Text(
                'Kamu tidak bisa keluar dari halaman ini selama timer berjalan (mode Kunci Aplikasi aktif). Hentikan timer dulu.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          title: const Text('Pomodoro Timer'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppTheme.primaryTeal,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 5),
                const Text(
                  'Stay Focused',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus on your task and avoid distractions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.txtGrey),
                ),
                const SizedBox(height: 22),

                // TIMER CIRCLE
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.card,
                    border:
                    Border.all(color: AppTheme.primaryTeal, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withOpacity(0.15),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                timerText,
                                style: const TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isRunning ? 'Focusing...' : 'Ready to focus',
                          style: TextStyle(
                              color: AppTheme.txtGrey, fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          selectedActivity.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // PILIH AKTIVITAS SEBELUM MEMULAI POMODORO
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mau fokus mengerjakan apa?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.txt,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activities.map((activity) {
                    final name = activity['name'] as String;
                    final selected = selectedActivity == name;
                    return ChoiceChip(
                      avatar: Icon(
                        activity['icon'] as IconData,
                        size: 18,
                        color: selected ? Colors.white : AppTheme.primaryTeal,
                      ),
                      label: Text(name),
                      selected: selected,
                      onSelected: isRunning
                          ? null
                          : (_) => setState(() => selectedActivity = name),
                      selectedColor: AppTheme.primaryTeal,
                      backgroundColor: AppTheme.card,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.txt,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppTheme.primaryTeal
                            : AppTheme.txtGrey.withOpacity(0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),

                // CHOOSE DURATION
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Choose Duration',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.txt)),
                ),
                const SizedBox(height: 12),

                // Preset row
                Row(
                  children: [
                    Expanded(child: _presetButton(15)),
                    const SizedBox(width: 8),
                    Expanded(child: _presetButton(25)),
                    const SizedBox(width: 8),
                    Expanded(child: _presetButton(45)),
                    const SizedBox(width: 8),
                    Expanded(child: _editButton()),
                  ],
                ),

                // ==========================================
                // DAFTAR CUSTOM PRESET
                // ==========================================
                if (customPresets.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text('Preset Tersimpan',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.txt)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${customPresets.length}',
                            style: const TextStyle(
                                color: AppTheme.primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(customPresets.length, (i) {
                    return _customPresetTile(i);
                  }),
                ] else ...[
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.txtGrey.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.bookmark_border,
                            size: 40,
                            color: AppTheme.txtGrey.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        Text(
                          'Belum ada preset tersimpan',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.txt),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap ikon ➕ untuk menambah waktu custom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.txtGrey),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                // PILIH MUSIK PENDAMPING
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.txtGrey.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Musik Pendamping',
                                  style: TextStyle(
                                    color: AppTheme.txt,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Opsional untuk menemani sesi fokus',
                                  style: TextStyle(
                                    color: AppTheme.txtGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...musicOptions.map((music) {
                        final name = music['name'] as String;
                        final selected = selectedMusic == name;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryTeal.withOpacity(0.10)
                                : AppTheme.bg,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryTeal
                                  : AppTheme.txtGrey.withOpacity(0.12),
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            leading: Icon(
                              music['icon'] as IconData,
                              color: AppTheme.primaryTeal,
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                color: AppTheme.txt,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              music['subtitle'] as String,
                              style: TextStyle(
                                color: AppTheme.txtGrey,
                                fontSize: 11,
                              ),
                            ),
                            trailing: Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: selected
                                  ? AppTheme.primaryTeal
                                  : AppTheme.txtGrey,
                              size: 24,
                            ),
                            onTap: () => _selectMusic(music),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Tombol fokus dan tombol akhiri yang meminta konfirmasi.
                Row(
                  children: [
                    Expanded(
                      flex: isRunning ? 3 : 1,
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: startTimer,
                          icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          label: Text(isRunning ? 'Pause' : 'Mulai Fokus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                    if (isRunning) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: _confirmEndSession,
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: const Text('End'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Timer'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _presetButton(int minutes) {
    final selected = activePreset == minutes;
    return GestureDetector(
      onTap: () => selectPreset(minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryTeal : AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected
                  ? AppTheme.primaryTeal
                  : AppTheme.txtGrey.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            '$minutes m',
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.txt,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _editButton() {
    return GestureDetector(
      onTap: _openCustomTimeDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppTheme.txtGrey.withOpacity(0.2)),
        ),
        child: Center(
          child: Icon(Icons.add, size: 20, color: AppTheme.primaryTeal),
        ),
      ),
    );
  }

  // TILE CUSTOM PRESET
  Widget _customPresetTile(int index) {
    final p = customPresets[index];
    final m = p['minutes'] as int;
    final s = p['seconds'] as int;
    final label = p['label'] as String? ?? _formatLabel(m, s);
    final isActive = activeCustomIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryTeal.withOpacity(0.15)
            : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppTheme.primaryTeal
              : AppTheme.txtGrey.withOpacity(0.15),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bookmark,
              size: 18,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? AppTheme.primaryTeal
                        : AppTheme.txt,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Durasi fokus',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.txtGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => selectCustomPreset(index),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primaryTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteCustomPreset(index),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}