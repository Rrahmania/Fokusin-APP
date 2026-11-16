import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'storage_service.dart';

class AiPerformanceReport {
  final int score;
  final String grade;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final String advice;

  const AiPerformanceReport({
    required this.score,
    required this.grade,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.advice,
  });

  factory AiPerformanceReport.fromJson(Map<String, dynamic> json) {
    return AiPerformanceReport(
      score: (json['score'] as num?)?.toInt() ?? 75,
      grade: json['grade'] as String? ?? 'B',
      summary: json['summary'] as String? ?? 'Performa fokusmu sudah cukup baik minggu ini.',
      strengths: (json['strengths'] as List?)?.map((e) => e.toString()).toList() ?? ['Konsistensi sesi fokus.'],
      improvements: (json['improvements'] as List?)?.map((e) => e.toString()).toList() ?? ['Tingkatkan jumlah sesi harian.'],
      advice: json['advice'] as String? ?? 'Pertahankan ritme belajar dan jangan lupa istirahat secukupnya.',
    );
  }
}

class AiRecommendationItem {
  final String title;
  final String description;
  final String duration;
  final String tag;

  const AiRecommendationItem({
    required this.title,
    required this.description,
    required this.duration,
    required this.tag,
  });
}

class AiService {
  static const String _defaultApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  static Future<String> _getApiKey() async {
    final savedKey = await StorageService.loadApiKey();
    if (savedKey.trim().isNotEmpty) return savedKey.trim();
    return _defaultApiKey;
  }

  /// Mendapatkan rekomendasi fokus cerdas dari Gemini AI berdasarkan statistik pengguna
  static Future<AiRecommendationItem> getRecommendation({
    required int todayPomodoro,
    required int streak,
    required int totalXp,
  }) async {
    final apiKey = await _getApiKey();

    if (apiKey.isEmpty) {
      return _fallbackRecommendation(todayPomodoro, streak);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      final prompt = '''
Kamu adalah "Focus AI", asisten produktivitas cerdas untuk aplikasi Fokusin.
Data pengguna saat ini:
- Sesi Pomodoro hari ini: $todayPomodoro
- Streak harian: $streak hari
- Total XP: $totalXp
- Waktu (Jam): ${DateTime.now().hour}:00

Berikan 1 rekomendasi fokus yang dipersonalisasi dan sangat memotivasi pengguna.
Jawab HANYA dalam format JSON berikut tanpa tanda backtick markdown:
{
  "title": "Judul rekomendasi singkat",
  "description": "Deskripsi inspiratif dan praktis (maksimal 2 kalimat)",
  "duration": "Durasi (contoh: 2 Pomodoro atau 25 Menit)",
  "tag": "Kategori singkat (contoh: Coding / Belajar / Refleksi)"
}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final rawText = response.text?.trim() ?? '';
      final cleanJson = _cleanJsonString(rawText);

      final map = jsonDecode(cleanJson) as Map<String, dynamic>;

      return AiRecommendationItem(
        title: map['title'] ?? 'Fokus Sesi Berikutnya',
        description: map['description'] ?? 'Selesaikan 1 sesi Pomodoro untuk menjaga konsistensi harianmu.',
        duration: map['duration'] ?? '1 Pomodoro',
        tag: map['tag'] ?? 'Fokus',
      );
    } catch (e) {
      debugPrint("AI Recommendation Error: $e");
      return _fallbackRecommendation(todayPomodoro, streak);
    }
  }

  /// Mengevaluasi kinerja fokus pengguna menggunakan Gemini AI
  static Future<AiPerformanceReport> evaluatePerformance({
    required int totalWeek,
    required double averageDaily,
    required int bestDayCount,
    required String bestDayName,
    required int currentStreak,
    required int totalXp,
    required Map<String, int> weekHistory,
  }) async {
    final apiKey = await _getApiKey();

    if (apiKey.isEmpty) {
      return _fallbackEvaluation(totalWeek, averageDaily, currentStreak, bestDayName);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      final prompt = '''
Kamu adalah Evaluator Kinerja AI untuk aplikasi produktivitas Fokusin.
Tugasmu adalah memberikan evaluasi analitis dan objektif mengenai kinerja fokus pengguna minggu ini.

Data Kinerja Minggu Ini:
- Total Sesi Pomodoro Minggu Ini: $totalWeek
- Rata-rata Sesi per Hari: ${averageDaily.toStringAsFixed(1)}
- Hari Terbaik: $bestDayName ($bestDayCount sesi)
- Streak Harian: $currentStreak hari
- Total XP Terkumpul: $totalXp
- Detail Riwayat Harian: $weekHistory

Kembalikan HANYA format JSON berikut (tanpa markdown backtick ```json):
{
  "score": 85,
  "grade": "A",
  "summary": "Ringkasan evaluasi produktivitas dalam 2 kalimat.",
  "strengths": ["Poin kelebihan 1", "Poin kelebihan 2"],
  "improvements": ["Poin area perbaikan 1", "Poin area perbaikan 2"],
  "advice": "Rekomendasi tindakan nyata untuk meningkatkan produktivitas minggu depan."
}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final rawText = response.text?.trim() ?? '';
      final cleanJson = _cleanJsonString(rawText);

      final map = jsonDecode(cleanJson) as Map<String, dynamic>;
      return AiPerformanceReport.fromJson(map);
    } catch (e) {
      debugPrint("AI Evaluation Error: $e");
      return _fallbackEvaluation(totalWeek, averageDaily, currentStreak, bestDayName);
    }
  }

  static String _cleanJsonString(String input) {
    var cleaned = input.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }

  static AiRecommendationItem _fallbackRecommendation(int today, int streak) {
    final hour = DateTime.now().hour;
    if (today == 0) {
      return const AiRecommendationItem(
        title: 'Mulai Sesi Pertama Hari Ini',
        description: 'Setiap pencapaian dimulai dari 1 sesi Pomodoro. Targetkan 25 menit fokus penuh sekarang!',
        duration: '1 Pomodoro',
        tag: 'Mulai Fokus',
      );
    } else if (today >= 4) {
      return AiRecommendationItem(
        title: 'Waktunya Istirahat & Pemulihan',
        description: 'Kamu sudah bekerja keras menyelesaikan $today sesi hari ini. Rehat sejenak untuk menyegarkan pikiran.',
        duration: '15 Menit Rehat',
        tag: 'Pemulihan',
      );
    } else if (hour >= 20) {
      return const AiRecommendationItem(
        title: 'Evaluasi & Persiapan Besok',
        description: 'Gunakan waktu malam untuk merapikan target esok hari dan menutup hari dengan tenang.',
        duration: '1 Pomodoro',
        tag: 'Refleksi',
      );
    } else {
      return AiRecommendationItem(
        title: 'Pertahankan Momentum Fokus',
        description: 'Streak $streak hari membuktikan komitmenmu. Selesaikan 1 sesi lagi untuk menambah XP!',
        duration: '2 Pomodoro',
        tag: 'Konsistensi',
      );
    }
  }

  static AiPerformanceReport _fallbackEvaluation(int totalWeek, double avg, int streak, String bestDay) {
    int score = ((totalWeek * 7) + (streak * 5)).clamp(35, 96);
    String grade = 'B';
    if (score >= 90) {
      grade = 'S';
    } else if (score >= 80) {
      grade = 'A';
    } else if (score >= 65) {
      grade = 'B';
    } else if (score >= 50) {
      grade = 'C';
    } else {
      grade = 'D';
    }

    return AiPerformanceReport(
      score: score,
      grade: grade,
      summary: totalWeek > 0
          ? 'Kamu berhasil menyelesaikan $totalWeek sesi minggu ini dengan rata-rata ${avg.toStringAsFixed(1)} sesi/hari.'
          : 'Belum ada aktivitas fokus yang signifikan tercatat minggu ini. Mari tingkatkan semangat!',
      strengths: [
        if (streak > 0) 'Mampu menjaga streak fokus selama $streak hari berturut-turut.' else 'Telah mengambil langkah untuk memulai fokus.',
        if (bestDay != '-') 'Hari terbaik produktivitasmu terjadi pada $bestDay.' else 'Siap mencapai rekor fokus baru minggu ini.',
      ],
      improvements: [
        if (avg < 3) 'Coba tingkatkan frekuensi sesi fokus harian minimal 3 sesi per hari.',
        'Atur jeda istirahat teratur untuk mencegah kelelahan mental.',
      ],
      advice: 'Tetapkan waktu fokus yang konsisten di jam yang sama setiap hari agar menjadi kebiasaan otomatis.',
    );
  }
}