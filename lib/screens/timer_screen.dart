import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/timer_service.dart';
import '../widgets/bottom_nav.dart';
import 'music_player_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TimerService _timer = TimerService.instance;
  List<Map<String, dynamic>> customPresets = [];
  bool lockApp = false;

  final List<Map<String, dynamic>> activities = [
    {'name': 'Belajar', 'icon': Icons.menu_book_rounded},
    {'name': 'Coding', 'icon': Icons.code_rounded},
    {'name': 'Tugas', 'icon': Icons.assignment_rounded},
    {'name': 'Bekerja', 'icon': Icons.work_outline_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
    _timer.addListener(_onTimerChanged);
    AppTheme.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _timer.removeListener(_onTimerChanged);
    AppTheme.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onTimerChanged() => mounted ? setState(() {}) : null;
  void _onThemeChanged() => mounted ? setState(() {}) : null;

  Future<void> _loadAll() async {
    final lock = await StorageService.loadLockApp();
    final presets = await StorageService.loadCustomPresets();
    if (!mounted) return;
    setState(() {
      lockApp = lock;
      customPresets = presets;
    });
  }

  Future<void> _openCustomTimeDialog() async {
    int tempHours = _timer.selectedMinutes ~/ 60;
    int tempMinutes = _timer.selectedMinutes % 60;
    int tempSeconds = _timer.selectedSeconds;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          height: 420,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Container(width: 45, height: 5, decoration: BoxDecoration(color: AppTheme.txtGrey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Atur Waktu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text('Max 3 jam', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: AppTheme.isDarkMode ? Brightness.dark : Brightness.light,
                    textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(color: AppTheme.txt, fontSize: 22, fontWeight: FontWeight.w600)),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hms,
                    initialTimerDuration: Duration(hours: tempHours, minutes: tempMinutes, seconds: tempSeconds),
                    minuteInterval: 1,
                    secondInterval: 1,
                    alignment: Alignment.center,
                    backgroundColor: Colors.transparent,
                    onTimerDurationChanged: (Duration d) {
                      int totalMin = d.inHours * 60 + d.inMinutes % 60;
                      if (totalMin > 180) return;
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
                          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.txt, side: BorderSide(color: AppTheme.border, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          child: const Text('Simpan'),
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
      final totalSeconds = tempHours * 3600 + tempMinutes * 60 + tempSeconds;
      if (totalSeconds < 1) return;

      final totalMinutes = tempHours * 60 + tempMinutes;
      String formatLabel(int m, int s) => '${m ~/ 60 > 0 ? "${m ~/ 60}j " : ""}${m % 60}m ${s}d';

      await StorageService.saveCustomPreset(minutes: totalMinutes, seconds: tempSeconds, label: '${_timer.selectedActivity} • ${formatLabel(totalMinutes, tempSeconds)}');
      final presets = await StorageService.loadCustomPresets();
      int newIndex = presets.indexWhere((p) => p['minutes'] == totalMinutes && p['seconds'] == tempSeconds);

      _timer.pause();
      if (!mounted) return;
      setState(() => customPresets = presets);
      _timer.selectCustomPreset(minutes: totalMinutes, seconds: tempSeconds, index: newIndex);
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: AppTheme.txtGrey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 20),
                        Text('Pengaturan & Preset', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(Icons.lock_outline, color: AppTheme.primary),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Kunci Aplikasi saat Timer Jalan', style: TextStyle(color: AppTheme.txt))),
                            Switch(
                              value: lockApp,
                              onChanged: (val) async {
                                setModalState(() => lockApp = val);
                                setState(() => lockApp = val);
                                await StorageService.saveLockApp(val);
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        if (customPresets.isEmpty)
                          Text('Belum ada preset tersimpan.', style: TextStyle(color: AppTheme.txtGrey))
                        else
                          ...customPresets.asMap().entries.map((entry) {
                            final i = entry.key;
                            final p = entry.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.bookmark, color: AppTheme.primary),
                              title: Text(p['label'] ?? 'Preset', style: TextStyle(color: AppTheme.txt)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await StorageService.deleteCustomPreset(p['minutes'] as int, p['seconds'] as int);
                                  final updatedPresets = await StorageService.loadCustomPresets();
                                  setModalState(() => customPresets = updatedPresets);
                                  setState(() => customPresets = updatedPresets);
                                },
                              ),
                              onTap: () {
                                Navigator.pop(bottomSheetContext);
                                _timer.selectCustomPreset(minutes: p['minutes'] as int, seconds: p['seconds'] as int, index: i);
                              },
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openMusic() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicPlayerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _timer.isRunning;
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = (screenWidth * 0.75).clamp(240.0, 320.0);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down, size: 32, color: AppTheme.txt),
          onPressed: () => BottomNav.navNotifier.value = 0,
        ),
        actions: [
          IconButton(icon: Icon(Icons.music_note, color: AppTheme.primary), onPressed: _openMusic),
          IconButton(icon: Icon(Icons.more_horiz, color: AppTheme.txt), onPressed: _openSettings),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: CircularProgressIndicator(
                    value: _timer.remainingSeconds / (_timer.selectedMinutes * 60 + _timer.selectedSeconds),
                    strokeWidth: 10,
                    backgroundColor: AppTheme.border,
                    color: AppTheme.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_timer.timerText, style: TextStyle(fontSize: 72, fontWeight: FontWeight.w300, color: AppTheme.txt, letterSpacing: -2)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(_timer.selectedActivity.toUpperCase(), style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(flex: 1),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final name = activities[index]['name'] as String;
                  final selected = _timer.selectedActivity == name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: isRunning ? null : () => _timer.setActivity(name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: 1.5),
                        ),
                        child: Center(
                          child: Text(name, style: TextStyle(color: selected ? Colors.white : AppTheme.txtGrey, fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRunning)
                  IconButton(onPressed: () => _timer.reset(), icon: Icon(Icons.stop_rounded, color: Colors.red.shade300, size: 40)),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: _timer.toggle,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 24),
                if (!isRunning)
                  IconButton(onPressed: _openCustomTimeDialog, icon: Icon(Icons.add_rounded, color: AppTheme.txt, size: 40)),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}