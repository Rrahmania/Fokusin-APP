import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/music_service.dart';

class GangTimerScreen extends StatefulWidget {
  final String gangName;
  final int durationMinutes;

  const GangTimerScreen({
    super.key,
    required this.gangName,
    required this.durationMinutes,
  });

  @override
  State<GangTimerScreen> createState() => _GangTimerScreenState();
}

class _GangTimerScreenState extends State<GangTimerScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  late int totalSeconds;
  late int remainingSeconds;
  bool isRunning = false;
  bool isFrozen = false;
  bool isFailed = false;
  Timer? _timer;

  Timer? _freezeTimer;
  int freezeRemainingSeconds = 0;

  int userXp = 0;
  final int costFreeze = 20;
  final int costAddTime = 30;
  final int costGangMusic = 10;
  final int rewardXp = 150;

  String activeStickerImage = '';

  late AnimationController _stickerController;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  final List<Map<String, String>> stickerList = [
    {'image': 'assets/images/happy.jpeg', 'sound': 'happy.mp3'},
    {'image': 'assets/images/sad.jpg', 'sound': 'sad.mp3'},
    {'image': 'assets/images/laugh.jpeg', 'sound': 'laugh.mp3'},
    {'image': 'assets/images/frustrated.jpeg', 'sound': 'frustrated.mp3'},
    {'image': 'assets/images/startled.jpg', 'sound': 'startled.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    totalSeconds = widget.durationMinutes * 60;
    remainingSeconds = totalSeconds;

    _stickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _loadXp();
    MusicService.instance.addListener(_onMusicChanged);

    // Cek apakah sebelumnya timer sudah berjalan (misal HP mati)
    _checkSavedTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _freezeTimer?.cancel();
    _stickerController.dispose();
    _sfxPlayer.dispose();
    MusicService.instance.removeListener(_onMusicChanged);
    super.dispose();
  }

  void _onMusicChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadXp() async {
    final xp = await StorageService.loadXp();
    if (mounted) setState(() => userXp = xp);
  }

  // --- LOGIKA BARU: ANTI HP MATI ---
  Future<void> _checkSavedTimer() async {
    final endTime = await StorageService.getTimerEndTime();
    if (endTime != null) {
      final now = DateTime.now();
      if (now.isAfter(endTime)) {
        // Timer selesai saat HP mati
        setState(() {
          isRunning = false;
          remainingSeconds = 0;
        });
        await StorageService.clearTimer();
        _completeGangSession();
      } else {
        // Timer masih berjalan, hitung sisa
        final diff = endTime.difference(now).inSeconds;
        setState(() {
          isRunning = true;
          remainingSeconds = diff;
        });
        _startTicker();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // JIKA APLIKASI DI-MINIMIZE/HP MATI:
    // Kita tidak lagi memanggil _handleExitPenalty() di sini agar timer tetap jalan.
    // Kita hanya mengecek sisa waktu saat aplikasi dibuka kembali.
    if (state == AppLifecycleState.resumed) {
      _checkSavedTimer();
    }
  }
  // ---------------------------------

  void _handleExitPenalty() {
    _timer?.cancel();
    _freezeTimer?.cancel();
    StorageService.clearTimer(); // Hapus timer jika user memaksa keluar
    setState(() {
      isRunning = false;
      isFailed = true;
      isFrozen = false;
      freezeRemainingSeconds = 0;
    });
  }

  void _toggleTimer() async {
    if (isFailed) {
      setState(() {
        isFailed = false;
        remainingSeconds = totalSeconds;
      });
      return;
    }

    if (isRunning) {
      // PAUSE TIMER
      _timer?.cancel();
      _freezeTimer?.cancel();
      await StorageService.clearTimer(); // Hapus target waktu di storage
      setState(() {
        isRunning = false;
        isFrozen = false;
        freezeRemainingSeconds = 0;
      });
    } else {
      // START TIMER
      setState(() => isRunning = true);

      // Simpan waktu target ke storage (Waktu sekarang + sisa detik)
      final endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
      await StorageService.saveTimerEndTime(endTime);

      _startTicker();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isFrozen) return;

      // Cek sisa waktu dari storage (agar akurat saat HP baru dinyalakan)
      final endTime = await StorageService.getTimerEndTime();
      if (endTime != null) {
        final diff = endTime.difference(DateTime.now()).inSeconds;
        if (diff <= 0) {
          _timer?.cancel();
          _completeGangSession();
        } else {
          if (mounted) setState(() => remainingSeconds = diff);
        }
      } else {
        // Fallback jika storage gagal dibaca
        if (remainingSeconds > 0) {
          if (mounted) setState(() => remainingSeconds--);
        } else {
          _timer?.cancel();
          _completeGangSession();
        }
      }
    });
  }

  Future<void> _completeGangSession() async {
    if (!mounted) return;
    setState(() {
      isRunning = false;
      remainingSeconds = 0;
    });
    MusicService.instance.stop();
    await StorageService.clearTimer();

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

  Future<bool> _payXp(int amount, String featureName) async {
    if (userXp < amount) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('XP tidak cukup! Butuh $amount XP untuk $featureName.'), backgroundColor: Colors.red),
      );
      return false;
    }

    final success = await StorageService.deductXp(amount);
    if (success) {
      _loadXp();
      MusicService.instance.userXp = await StorageService.loadXp();

      if (!mounted) return false;
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
      // Update sisa waktu dan simpan target waktu baru
      final newRemaining = remainingSeconds + (5 * 60);
      final newEndTime = DateTime.now().add(Duration(seconds: newRemaining));
      await StorageService.saveTimerEndTime(newEndTime);

      setState(() {
        remainingSeconds = newRemaining;
        totalSeconds += 5 * 60;
      });
    }
  }

  void _openGangMusic() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: AppTheme.txtGrey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Musik Gang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                        child: Text('$costGangMusic XP / Lagu', style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Musik akan didengar oleh semua anggota Gang.', style: TextStyle(color: AppTheme.txtGrey, fontSize: 13)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: MusicService.instance.playlist.length,
                      itemBuilder: (context, index) {
                        final track = MusicService.instance.playlist[index];
                        final isCurrent = MusicService.instance.currentIndex == index;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 45, height: 45,
                            decoration: BoxDecoration(color: track.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                            child: Icon(track.icon, color: track.color),
                          ),
                          title: Text(track.title, style: TextStyle(color: isCurrent ? AppTheme.primary : AppTheme.txt, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Text(track.artist, style: TextStyle(color: AppTheme.txtGrey, fontSize: 12)),
                          trailing: isCurrent
                              ? Icon(Icons.graphic_eq, color: AppTheme.primary)
                              : Text('Putar', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          onTap: () async {
                            if (isCurrent) {
                              MusicService.instance.togglePlay(forcePlay: true);
                              setModalState(() {});
                              setState(() {});
                              return;
                            }

                            bool success = await _payXp(costGangMusic, 'Memutar ${track.title}');
                            if (success) {
                              MusicService.instance.selectTrack(index, forcePlay: true);
                              MusicService.instance.playAudio(forcePlay: true);
                              setModalState(() {});
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _sendSticker(String imagePath, String soundFile) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      debugPrint("Gagal memutar suara SFX: $e");
    }

    setState(() => activeStickerImage = imagePath);
    _stickerController.forward(from: 0);
  }

  String _formatTime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');

    if (seconds >= 3600) {
      return '$h:$m:$s';
    }
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
                        MusicService.instance.stop();
                        _handleExitPenalty(); // Paksa gagal jika user menekan tombol keluar
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            } else {
              MusicService.instance.stop();
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
                MusicService.instance.isPlaying ? Icons.music_note : Icons.music_off,
                color: MusicService.instance.isPlaying ? AppTheme.primary : AppTheme.txt
            ),
            onPressed: _openGangMusic,
            tooltip: 'Putar Musik Gang',
          ),
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
      // BUNGKUS DENGAN LAYOUT BUILDER & SCROLL VIEW AGAR ANTI OVERFLOW
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
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
                                  SizedBox(
                                    width: 200,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _formatTime(remainingSeconds),
                                        style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppTheme.txt),
                                      ),
                                    ),
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
                                  const Text('Kamu keluar dari aplikasi! Sesi dibatalkan.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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

                          if (MusicService.instance.isPlaying || MusicService.instance.currentPosition > Duration.zero)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(MusicService.instance.current.icon, color: AppTheme.primary, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(MusicService.instance.current.title, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text('Didengar oleh semua anggota', style: TextStyle(fontSize: 10, color: AppTheme.txtGrey)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      MusicService.instance.togglePlay(forcePlay: true);
                                      setState((){});
                                    },
                                    icon: Icon(MusicService.instance.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: AppTheme.primary, size: 32),
                                  )
                                ],
                              ),
                            ),

                          const SizedBox(height: 10),

                          if (!isFailed)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: AppTheme.card,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: stickerList.map((sticker) {
                                  return GestureDetector(
                                    onTap: () => _sendSticker(sticker['image']!, sticker['sound']!),
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                          color: AppTheme.bg,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppTheme.border, width: 1.5)
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          sticker['image']!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(child: Icon(Icons.broken_image, size: 24, color: Colors.grey));
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                if (activeStickerImage.isNotEmpty)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _stickerController,
                        builder: (context, child) {
                          final value = _stickerController.value;

                          double scale = 1.0;
                          if (value < 0.2) {
                            scale = Curves.easeOutBack.transform(value / 0.2);
                          }

                          double translateY = -120 * value;

                          double opacity = 1.0;
                          if (value > 0.7) {
                            opacity = 1.0 - ((value - 0.7) / 0.3);
                          }

                          return Transform.translate(
                            offset: Offset(0, translateY),
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity.clamp(0.0, 1.0),
                                child: Center(
                                  child: Image.asset(
                                    activeStickerImage,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
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