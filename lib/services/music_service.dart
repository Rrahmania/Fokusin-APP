import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/music_model.dart';
import 'storage_service.dart';

class MusicService extends ChangeNotifier with WidgetsBindingObserver {
  static final MusicService instance = MusicService._internal();
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  List<MusicTrack> playlist = List.from(defaultPlaylist);
  List<String> ownedTracks = []; // Menyimpan judul musik yang sudah dibeli permanen
  int currentIndex = 0;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  int userXp = 0;

  bool _isInitialized = false;
  MusicTrack get current => playlist[currentIndex];

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Daftarkan observer untuk memantau jika aplikasi masuk background
    WidgetsBinding.instance.addObserver(this);

    _setupAudioContext();
    _setupAudioListeners();
    _loadSaved();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Jika aplikasi di-minimize atau tidak aktif, pause musik
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (isPlaying) {
        _audioPlayer.pause();
      }
    }
  }

  void _setupAudioContext() {
    // DIBUNGKUS TRY-CATCH UNTUK MENCEGAH CRASH DI IOS
    try {
      _audioPlayer.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          audioMode: AndroidAudioMode.normal,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ));
    } catch (e) {
      debugPrint("Gagal set AudioContext: $e");
    }
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

  Future<void> reloadPlaylist() async {
    final customTracks = await StorageService.loadCustomMusicTracks();
    playlist = [...defaultPlaylist, ...customTracks];
    notifyListeners();
  }

  Future<void> _loadSaved() async {
    userXp = await StorageService.loadXp();
    ownedTracks = await StorageService.loadOwnedMusic();
    final customTracks = await StorageService.loadCustomMusicTracks();
    playlist = [...defaultPlaylist, ...customTracks];

    final saved = await StorageService.loadSelectedMusic();
    final idx = playlist.indexWhere((t) => t.title == saved);
    if (idx >= 0) {
      currentIndex = idx;
    }
    _prepareTrack(currentIndex, autoPlay: false);
  }

  bool isTrackOwned(String title) {
    return ownedTracks.contains(title);
  }

  Future<bool> purchaseTrack(int index) async {
    final track = playlist[index];
    if (track.price <= 0 || ownedTracks.contains(track.title)) return true;

    final currentXp = await StorageService.loadXp();
    if (currentXp < track.price) return false;

    await StorageService.saveXp(currentXp - track.price);
    userXp = currentXp - track.price;
    ownedTracks.add(track.title);
    await StorageService.saveOwnedMusic(ownedTracks);
    notifyListeners();
    return true;
  }

  Future<void> _prepareTrack(int index, {bool autoPlay = true}) async {
    await _audioPlayer.stop();
    currentIndex = index;
    currentPosition = Duration.zero;
    totalDuration = Duration(seconds: current.durationSeconds);
    notifyListeners();

    if (autoPlay) {
      playAudio();
    }
  }

  Future<void> playAudio({bool forcePlay = false}) async {
    // Jika bukan forcePlay (bukan dari Gang), cek apakah dia berhak memutar
    if (!forcePlay && current.price > 0 && !isTrackOwned(current.title)) return;

    try {
      await _audioPlayer.play(AssetSource(current.filePath));
      StorageService.saveSelectedMusic(current.title);
    } catch (e) {
      debugPrint("ERROR PUTAR AUDIO: $e");
    }
  }

  void togglePlay({bool forcePlay = false}) {
    if (!forcePlay && current.price > 0 && !isTrackOwned(current.title)) return;

    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      if (currentPosition == Duration.zero) {
        playAudio(forcePlay: forcePlay);
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

  void selectTrack(int index, {bool forcePlay = false}) {
    _prepareTrack(index, autoPlay: forcePlay);
    if (!forcePlay) {
      // Jika dipilih dari beranda dan belum beli, jangan autoplay
      if (current.price > 0 && !isTrackOwned(current.title)) {
        _audioPlayer.pause();
      } else {
        playAudio();
      }
    }
  }

  void stop() {
    _audioPlayer.stop();
    isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }
}