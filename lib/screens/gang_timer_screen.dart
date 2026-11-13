import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class GangTimerScreen extends StatefulWidget {
  final String gangName;
  final int durationMinutes; // <-- PARAMETER BARU

  const GangTimerScreen({
    super.key,
    required this.gangName,
    required this.durationMinutes, // <-- WAJIB DIISI
  });

  @override
  State<GangTimerScreen> createState() => _GangTimerScreenState();
}

class _GangTimerScreenState extends State<GangTimerScreen> with WidgetsBindingObserver {
  // State Timer
  late int totalSeconds;
  late int remainingSeconds;
  bool isRunning = false;
  bool isFrozen = false;
  bool isFailed = false;
  Timer? _timer;

  // State Freeze Timer
  Timer? _freezeTimer;
  int freezeRemainingSeconds = 0;

  // State Stiker & Ekonomi XP
  int userXp = 0;
  final int costFreeze = 20;
  final int costAddTime = 30;
  final int rewardXp = 150;
  String activeSticker = '';
  Timer? _stickerTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inisialisasi waktu berdasarkan durasi dari Leader
    totalSeconds = widget.durationMinutes * 60;
    remainingSeconds = totalSeconds;

    _loadXp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _freezeTimer?.cancel();
    _stickerTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadXp() async {
    final xp = await StorageService.loadXp();
    if (mounted) setState(() => userXp = xp);
  }

  // --- LOGIKA DETEKSI KELUAR APLIKASI ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && isRunning) {
      _handleExitPenalty();
    }
  }

  void _handleExitPenalty() {
    _timer?.cancel();
    _freezeTimer?.cancel();
    setState(() {
      isRunning = false;
      isFailed = true;
      isFrozen = false;
      freezeRemainingSeconds = 0;
    });
  }

  // --- LOGIKA TIMER UTAMA ---
  void _toggleTimer() {
    if (isFailed) {
      setState(() {
        isFailed = false;
        remainingSeconds = totalSeconds;
      });
      return;
    }

    if (isRunning) {
      _timer?.cancel();
      _freezeTimer?.cancel();
      setState(() {
        isRunning = false;
        isFrozen = false;
        freezeRemainingSeconds = 0;
      });
    } else {
      setState(() => isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (isFrozen) return;

        if (remainingSeconds > 0) {
          setState(() => remainingSeconds--);
        } else {
          _timer?.cancel();
          _completeGangSession();
        }
      });
    }
  }

  Future<void> _completeGangSession() async {
    setState(() => isRunning = false);

    int currentXp = await StorageService.loadXp();
    await StorageService.saveXp(currentXp + rewardXp);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Gang Focus Selesai! 🎉'),
        content: Text('Luar biasa! Tim ${widget.gangName} berhasil menyelesaikan sesi fokus.\n\n+$rewardXp XP untukmu.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kembali'),
          )
        ],
      ),
    );
  }

  // --- FITUR BAYAR PAKAI XP ---
  Future<bool> _payXp(int amount, String featureName) async {
    if (userXp < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('XP tidak cukup! Butuh $amount XP untuk $featureName.'), backgroundColor: Colors.red),
      );
      return false;
    }

    final success = await StorageService.deductXp(amount);
    if (success) {
      _loadXp();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('-$amount XP. $featureName berhasil digunakan!'), backgroundColor: AppTheme.darkTeal),
      );
    }
    return success;
  }

  void _toggleFreeze() async {
    if (!isRunning) return;

    if (!isFrozen) {
      bool success = await _payXp(costFreeze, 'Freeze Time (20s)');
      if (success) {
        setState(() {
          isFrozen = true;
          freezeRemainingSeconds = 20;
        });
        _startFreezeTimer();
      }
    } else {
      _stopFreezeTimer();
      setState(() => isFrozen = false);
    }
  }

  void _startFreezeTimer() {
    _freezeTimer?.cancel();
    _freezeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (freezeRemainingSeconds > 0) {
        setState(() => freezeRemainingSeconds--);
      } else {
        _stopFreezeTimer();
        if (mounted) {
          setState(() => isFrozen = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Waktu Freeze habis! Timer kembali berjalan.'), backgroundColor: Colors.blue),
          );
        }
      }
    });
  }

  void _stopFreezeTimer() {
    _freezeTimer?.cancel();
    freezeRemainingSeconds = 0;
  }

  void _addTime() async {
    if (!isRunning) return;

    bool success = await _payXp(costAddTime, 'Tambah Waktu (+5 Menit)');
    if (success) {
      setState(() {
        remainingSeconds += 5 * 60;
        totalSeconds += 5 * 60;
      });
    }
  }

  void _sendSticker(String emoji) {
    if (!isRunning) return;
    setState(() => activeSticker = emoji);

    _stickerTimer?.cancel();
    _stickerTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => activeSticker = '');
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('Gang Timer: ${widget.gangName}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (isRunning) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Keluar?'),
                  content: const Text('Jika keluar saat timer berjalan, sesi akan hangus dan kamu tidak mendapat XP.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('$userXp XP', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt)),
                ],
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('Sesi Gang (${widget.durationMinutes} Menit)', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: remainingSeconds / totalSeconds,
                        strokeWidth: 12,
                        backgroundColor: AppTheme.border,
                        color: isFailed ? Colors.red : (isFrozen ? Colors.blue : AppTheme.primary),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          _formatTime(remainingSeconds),
                          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppTheme.txt),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isFailed
                              ? 'GAGAL'
                              : (isFrozen
                              ? 'FROZEN ❄️ ($freezeRemainingSeconds s)'
                              : (isRunning ? 'FOCUSING...' : 'SIAP')),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: isFailed ? Colors.red : (isFrozen ? Colors.blue : AppTheme.primary)
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const Spacer(),

                if (isFailed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text('Kamu keluar dari aplikasi! Sesi dibatalkan.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _toggleTimer,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('ULANGI SESI (RESET)'),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.ac_unit,
                        label: isFrozen ? 'Unfreeze' : 'Freeze\n(20s)',
                        color: isFrozen ? Colors.blue : AppTheme.card,
                        iconColor: isFrozen ? Colors.white : Colors.blue,
                        onTap: _toggleFreeze,
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: _toggleTimer,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 15)],
                          ),
                          child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 24),
                      _buildActionButton(
                        icon: Icons.add_alarm,
                        label: '+5 Min\n($costAddTime XP)',
                        color: AppTheme.card,
                        iconColor: AppTheme.primary,
                        onTap: _addTime,
                      ),
                    ],
                  ),
                const SizedBox(height: 50),

                if (!isFailed)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: AppTheme.card,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['👍', '🔥', '💪', '😴', '🍅'].map((emoji) {
                        return GestureDetector(
                          onTap: () => _sendSticker(emoji),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.bg, shape: BoxShape.circle),
                            child: Text(emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
            if (activeSticker.isNotEmpty)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(activeSticker, style: const TextStyle(fontSize: 80)),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required Color iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: AppTheme.border, width: 1.5)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.txtGrey)),
        ],
      ),
    );
  }
}