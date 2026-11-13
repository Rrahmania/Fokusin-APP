import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/music_model.dart';
import 'storage_service.dart';

class MusicService extends ChangeNotifier {
  static final MusicService instance = MusicService._internal();
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  List<MusicTrack> playlist = List.from(defaultPlaylist);
  int currentIndex = 0;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  int userXp = 0;

  bool _isInitialized = false;
  MusicTrack get current => playlist[currentIndex];

  // Fungsi inisialisasi dipanggil sekali di main.dart
  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
    _setupAudioContext();
    _setupAudioListeners();
    _loadSaved();
  }

  void _setupAudioContext() {
    _audioPlayer.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        audioMode: AndroidAudioMode.normal,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    ));
  }

  void _setupAudioListeners() {
    _audioPlayer.onPositionChanged.listen((Duration duration) {
      currentPosition = duration;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      totalDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      next();
    });
  }

  Future<void> _loadSaved() async {
    userXp = await StorageService.loadXp();
    final saved = await StorageService.loadSelectedMusic();
    final idx = playlist.indexWhere((t) => t.title == saved);
    if (idx >= 0) {
      currentIndex = idx;
    }
    _prepareTrack(currentIndex, autoPlay: false);
  }

  Future<void> _prepareTrack(int index, {bool autoPlay = true}) async {
    await _audioPlayer.stop();
    currentIndex = index;
    currentPosition = Duration.zero;
    totalDuration = Duration(seconds: current.durationSeconds);
    notifyListeners();

    if (autoPlay && userXp >= current.requiredXp) {
      playAudio();
    }
  }

  Future<void> playAudio() async {
    try {
      await _audioPlayer.play(AssetSource(current.filePath));
      StorageService.saveSelectedMusic(current.title);
    } catch (e) {
      debugPrint("ERROR PUTAR AUDIO: $e");
    }
  }

  void togglePlay() {
    if (userXp < current.requiredXp) return;

    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      if (currentPosition == Duration.zero) {
        playAudio();
      } else {
        _audioPlayer.resume();
      }
    }
  }

  void next() {
    int nextIndex = (currentIndex + 1) % playlist.length;
    _prepareTrack(nextIndex);
  }

  void prev() {
    int prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    _prepareTrack(prevIndex);
  }

  void selectTrack(int index) {
    _prepareTrack(index);
  }

  void stop() {
    _audioPlayer.stop();
    isPlaying = false;
    notifyListeners();
  }
}