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
    final history = await StorageService.loadPomodoroHistory();
    final totalAll = await StorageService.loadTotalPomodoro();
    final streak = await StorageService.loadStreak();
    final xp = await StorageService.loadXp();

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
      totalXp = xp;
      isLoading = false;
    });
  }

  String _dayName(int weekday) {
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return names[weekday - 1];
  }

  String _dayNameFull(int weekday) {
    const names = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return names[weekday - 1];
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}';
  }

  String _formatDateFull(DateTime d) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
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

  // BOTTOM SHEET DETAIL HARI
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
      message = isToday
          ? 'Belum ada Pomodoro hari ini. Yuk mulai fokus!'
          : 'Hari ini kamu belum sempat fokus. Tidak apa-apa, besok lebih baik!';
      statusIcon = Icons.sentiment_dissatisfied_rounded;
      statusColor = Colors.orange;
    } else if (count < 3) {
      message = 'Awal yang bagus! Coba tambah lagi besok.';
      statusIcon = Icons.thumb_up_rounded;
      statusColor = AppTheme.primaryTeal;
    } else if (count < 6) {
      message = 'Produktif banget! Pertahankan ya.';
      statusIcon = Icons.local_fire_department_rounded;
      statusColor = Colors.orange;
    } else {
      message = 'Luar biasa! Kamu mesin fokus sejati 🚀';
      statusIcon = Icons.emoji_events_rounded;
      statusColor = Colors.amber;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
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
                  decoration: BoxDecoration(
                    color: AppTheme.txtGrey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: AppTheme.primaryTeal, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _dayNameFull(date.weekday),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.txt,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Hari ini',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateFull(date),
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.txtGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Big count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: count > 0
                        ? [AppTheme.primaryTeal, AppTheme.darkTeal]
                        : [
                      AppTheme.txtGrey.withOpacity(0.6),
                      AppTheme.txtGrey.withOpacity(0.4)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.timer,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pomodoro selesai',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 👇 GANTI TOMAT → JAM PASIR
                    const Text('⏳', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.txt,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Statistik Mingguan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryTeal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.bar_chart_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Minggu Ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '$totalWeek',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total Pomodoro minggu ini',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // BAR CHART
              Text('Grafik Harian',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.txt)),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekData.map((entry) {
                      final maxVal = weekData
                          .map((e) => e.value)
                          .reduce((a, b) => a > b ? a : b);
                      final ratio =
                      maxVal == 0 ? 0.0 : entry.value / maxVal;
                      final isToday = _isToday(entry.key);
                      final isFuture = _isFuture(entry.key);
                      return _BarColumn(
                        label: _dayName(entry.key.weekday),
                        date: _formatDate(entry.key),
                        value: entry.value,
                        ratio: ratio,
                        isToday: isToday,
                        isFuture: isFuture,
                        onTap: () =>
                            _showDayDetail(entry.key, entry.value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // SUMMARY
              Text('Ringkasan',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.txt)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.trending_up,
                      value: average.toStringAsFixed(1),
                      label: 'Rata-rata/hari',
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.emoji_events,
                      value: '$bestDay',
                      label: 'Hari Terbaik ($bestDayName)',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.timer,
                      value: '$totalAllTime',
                      label: 'Total All-time',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.local_fire_department,
                      value: '$currentStreak',
                      label: 'Streak Sekarang',
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.star,
                      value: '$totalXp',
                      label: 'Total XP',
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: SizedBox()),
                ],
              ),

              const SizedBox(height: 25),

              // DETAIL LIST
              Row(
                children: [
                  Text('Detail Harian',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.txt)),
                  const SizedBox(width: 8),
                  Icon(Icons.touch_app_rounded,
                      size: 16, color: AppTheme.txtGrey),
                  const SizedBox(width: 4),
                  Text('Tap untuk detail',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.txtGrey)),
                ],
              ),
              const SizedBox(height: 12),
              ...weekData.map((entry) {
                return _DailyRow(
                  dayName: _dayName(entry.key.weekday),
                  date: _formatDate(entry.key),
                  value: entry.value,
                  isToday: _isToday(entry.key),
                  isFuture: _isFuture(entry.key),
                  onTap: () =>
                      _showDayDetail(entry.key, entry.value),
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BAR COLUMN
// ============================================================
class _BarColumn extends StatelessWidget {
  final String label;
  final String date;
  final int value;
  final double ratio;
  final bool isToday;
  final bool isFuture;
  final VoidCallback onTap;

  const _BarColumn({
    required this.label,
    required this.date,
    required this.value,
    required this.ratio,
    required this.isToday,
    required this.isFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: value > 0 ? AppTheme.primaryTeal : AppTheme.txtGrey,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 26,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.lightTeal.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: 26,
                height: (120 * ratio).clamp(4.0, 120.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFuture
                        ? [
                      AppTheme.txtGrey.withOpacity(0.3),
                      AppTheme.txtGrey.withOpacity(0.5),
                    ]
                        : isToday
                        ? [AppTheme.primaryTeal, AppTheme.darkTeal]
                        : [
                      AppTheme.primaryTeal.withOpacity(0.7),
                      AppTheme.primaryTeal,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              color: isToday ? AppTheme.primaryTeal : AppTheme.txtGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.txt,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppTheme.txtGrey),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DAILY ROW
// ============================================================
class _DailyRow extends StatelessWidget {
  final String dayName;
  final String date;
  final int value;
  final bool isToday;
  final bool isFuture;
  final VoidCallback onTap;

  const _DailyRow({
    required this.dayName,
    required this.date,
    required this.value,
    required this.isToday,
    required this.isFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isFuture ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isToday
                ? AppTheme.primaryTeal.withOpacity(0.08)
                : AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: isToday
                ? Border.all(color: AppTheme.primaryTeal.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: value > 0
                      ? AppTheme.primaryTeal.withOpacity(0.15)
                      : AppTheme.txtGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.timer,
                  size: 18,
                  color: value > 0 ? AppTheme.primaryTeal : AppTheme.txtGrey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.txt,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Hari ini',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.txtGrey),
                    ),
                  ],
                ),
              ),

              Text(
                '$value ⏳',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: value > 0 ? AppTheme.primaryTeal : AppTheme.txtGrey,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppTheme.txtGrey.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}