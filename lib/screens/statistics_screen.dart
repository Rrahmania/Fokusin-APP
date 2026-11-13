import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isLoading = true;
  int userXp = 0;
  List<MapEntry<DateTime, int>> weekData = [];
  int totalWeek = 0;
  int bestDay = 0;
  String bestDayName = '-';
  double average = 0;
  int totalAllTime = 0;
  int currentStreak = 0;
  int totalXp = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    userXp = await StorageService.loadXp();
    final history = await StorageService.loadPomodoroHistory();
    final totalAll = await StorageService.loadTotalPomodoro();
    final streak = await StorageService.loadStreak();

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayDate = DateTime(monday.year, monday.month, monday.day);

    final week = <MapEntry<DateTime, int>>[];
    for (int i = 0; i < 7; i++) {
      final date = mondayDate.add(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      week.add(MapEntry(date, history[key] ?? 0));
    }

    final totalW = week.fold<int>(0, (sum, e) => sum + e.value);

    int best = 0;
    String bestName = '-';
    for (final e in week) {
      if (e.key.isAfter(now)) continue;
      if (e.value > best) {
        best = e.value;
        bestName = _dayName(e.key.weekday);
      }
    }

    int daysElapsed = 0;
    for (final e in week) {
      if (!e.key.isAfter(now)) daysElapsed++;
    }
    final avg = daysElapsed > 0 ? totalW / daysElapsed : 0.0;

    if (!mounted) return;
    setState(() {
      weekData = week;
      totalWeek = totalW;
      bestDay = best;
      bestDayName = bestName;
      average = avg;
      totalAllTime = totalAll;
      currentStreak = streak;
      totalXp = userXp;
      isLoading = false;
    });
  }

  String _dayName(int weekday) {
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return names[weekday - 1];
  }

  String _dayNameFull(int weekday) {
    const names = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return names[weekday - 1];
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}';

  String _formatDateFull(DateTime d) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isFuture(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return d.isAfter(today);
  }

  void _showDayDetail(DateTime date, int count) {
    final isToday = _isToday(date);
    final isFuture = _isFuture(date);

    String message;
    IconData statusIcon;
    Color statusColor;

    if (isFuture) {
      message = 'Hari ini belum terjadi. Ayo tetap semangat!';
      statusIcon = Icons.schedule_rounded;
      statusColor = AppTheme.txtGrey;
    } else if (count == 0) {
      message = isToday ? 'Belum ada Pomodoro hari ini. Yuk mulai fokus!' : 'Hari ini kamu belum sempat fokus. Tidak apa-apa, besok lebih baik!';
      statusIcon = Icons.sentiment_dissatisfied_rounded;
      statusColor = Colors.orange;
    } else if (count < 3) {
      message = 'Awal yang bagus! Coba tambah lagi besok.';
      statusIcon = Icons.thumb_up_rounded;
      statusColor = AppTheme.primary;
    } else if (count < 6) {
      message = 'Produktif banget! Pertahankan ya.';
      statusIcon = Icons.local_fire_department_rounded;
      statusColor = Colors.orange;
    } else {
      message = 'Luar biasa! Kamu mesin fokus sejati 🚀';
      statusIcon = Icons.emoji_events_rounded;
      statusColor = AppTheme.accent;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(color: AppTheme.txtGrey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 24), // Hapus const
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(_dayNameFull(date.weekday), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Hari ini', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(_formatDateFull(date), style: TextStyle(fontSize: 13, color: AppTheme.txtGrey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: count > 0 ? AppTheme.primary : AppTheme.border, borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.timer, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$count', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold, height: 1)),
                        const SizedBox(height: 4),
                        const Text('Pomodoro selesai', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const Spacer(),
                    const Text('⏳', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: Text(message, style: TextStyle(fontSize: 13, color: AppTheme.txt, height: 1.4))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLockedStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock, size: 40, color: Colors.orange),
          const SizedBox(height: 16),
          Text('Statistik Terkunci', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
          const SizedBox(height: 8),
          Text('Kumpulkan 300 XP untuk membuka detail grafik mingguan.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.txtGrey)),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: (userXp / 300).clamp(0.0, 1.0), backgroundColor: AppTheme.border, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text('$userXp / 300 XP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Statistik Mingguan'), centerTitle: false, backgroundColor: AppTheme.bg, elevation: 0),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Minggu Ini', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('$totalWeek', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold, height: 1)),
                    const SizedBox(height: 4),
                    const Text('Total Pomodoro minggu ini', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- LOGIKA KUNCI STATISTIK (300 XP) ---
              if (userXp >= 300) ...[
                Text('Grafik Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
                  child: SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekData.map((entry) {
                        final maxVal = weekData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
                        final ratio = maxVal == 0 ? 0.0 : entry.value / maxVal;
                        return _BarColumn(
                          label: _dayName(entry.key.weekday),
                          date: _formatDate(entry.key),
                          value: entry.value,
                          ratio: ratio,
                          isToday: _isToday(entry.key),
                          isFuture: _isFuture(entry.key),
                          onTap: () => _showDayDetail(entry.key, entry.value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Ringkasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _SummaryCard(icon: Icons.trending_up, value: average.toStringAsFixed(1), label: 'Rata-rata/hari', color: AppTheme.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryCard(icon: Icons.emoji_events, value: '$bestDay', label: 'Hari Terbaik ($bestDayName)', color: AppTheme.accent)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _SummaryCard(icon: Icons.timer, value: '$totalAllTime', label: 'Total All-time', color: Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryCard(icon: Icons.local_fire_department, value: '$currentStreak', label: 'Streak Sekarang', color: Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Text('Detail Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                    const SizedBox(width: 8),
                    Icon(Icons.touch_app_rounded, size: 16, color: AppTheme.txtGrey), // Hapus const
                    const SizedBox(width: 4),
                    Text('Tap untuk detail', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                  ],
                ),
                const SizedBox(height: 16),
                ...weekData.map((entry) {
                  return _DailyRow(
                    dayName: _dayName(entry.key.weekday),
                    date: _formatDate(entry.key),
                    value: entry.value,
                    isToday: _isToday(entry.key),
                    isFuture: _isFuture(entry.key),
                    onTap: () => _showDayDetail(entry.key, entry.value),
                  );
                }).toList(),
              ] else ...[
                _buildLockedStats(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final String label;
  final String date;
  final int value;
  final double ratio;
  final bool isToday;
  final bool isFuture;
  final VoidCallback onTap;

  const _BarColumn({required this.label, required this.date, required this.value, required this.ratio, required this.isToday, required this.isFuture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: value > 0 ? AppTheme.primary : AppTheme.txtGrey)),
          const SizedBox(height: 6),
          Container(
            width: 28,
            height: 120,
            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(8)),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: 28,
                height: (120 * ratio).clamp(4.0, 120.0),
                decoration: BoxDecoration(
                  color: isFuture ? AppTheme.txtGrey.withValues(alpha: 0.3) : (isToday ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.7)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: isToday ? AppTheme.primary : AppTheme.txtGrey)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.txt)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final String dayName;
  final String date;
  final int value;
  final bool isToday;
  final bool isFuture;
  final VoidCallback onTap;

  const _DailyRow({required this.dayName, required this.date, required this.value, required this.isToday, required this.isFuture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isFuture ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isToday ? AppTheme.primary.withValues(alpha: 0.05) : AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isToday ? AppTheme.primary.withValues(alpha: 0.5) : AppTheme.border, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: value > 0 ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.border, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.timer, size: 18, color: value > 0 ? AppTheme.primary : AppTheme.txtGrey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(dayName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.txt)),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(6)),
                            child: const Text('Hari ini', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(date, style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                  ],
                ),
              ),
              Text('$value ⏳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: value > 0 ? AppTheme.primary : AppTheme.txtGrey)),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.txtGrey.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}