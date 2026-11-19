import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/shop_model.dart';
import '../models/music_model.dart'; // TAMBAHAN
import '../services/storage_service.dart';
import '../services/music_service.dart'; // TAMBAHAN
import '../widgets/framed_avatar.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int xp = 0;
  List<String> ownedFrames = ['default'];
  String equippedFrame = 'default';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userXp = await StorageService.loadXp();
    final owned = await StorageService.loadOwnedFrames();
    final equipped = await StorageService.loadEquippedFrame();
    if (!mounted) return;
    setState(() {
      xp = userXp;
      ownedFrames = owned;
      equippedFrame = equipped;
      isLoading = false;
    });
  }

  // ================= LOGIKA BELI FRAME =================
  Future<void> _buyFrame(AvatarFrame frame) async {
    if (xp < frame.price) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('XP kamu tidak cukup! Butuh ${frame.price} XP.'), backgroundColor: Colors.red));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Beli ${frame.name}?'),
        content: Text('Gunakan ${frame.price} XP untuk membeli frame ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
            child: const Text('Beli', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final newOwned = [...ownedFrames, frame.id];
    final newXp = xp - frame.price;

    await StorageService.saveOwnedFrames(newOwned);
    await StorageService.saveXp(newXp);
    await StorageService.saveEquippedFrame(frame.id);

    if (!mounted) return;
    setState(() {
      ownedFrames = newOwned;
      xp = newXp;
      equippedFrame = frame.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${frame.name} berhasil dibeli! 🎉'), backgroundColor: AppTheme.darkTeal));
  }

  Future<void> _equipFrame(AvatarFrame frame) async {
    await StorageService.saveEquippedFrame(frame.id);
    if (!mounted) return;
    setState(() => equippedFrame = frame.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${frame.name} dipakai! ✨'), backgroundColor: AppTheme.darkTeal));
  }

  // ================= LOGIKA BELI MUSIK =================
  Future<void> _buyMusic(int index, MusicTrack track) async {
    if (xp < track.price) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('XP kamu tidak cukup! Butuh ${track.price} XP.'), backgroundColor: Colors.red));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Beli ${track.title}?'),
        content: Text('Gunakan ${track.price} XP untuk membeli musik ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
            child: const Text('Beli', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Panggil fungsi purchaseTrack dari MusicService
    final success = await MusicService.instance.purchaseTrack(index);

    if (!mounted) return;

    if (success) {
      await _load(); // Reload XP setelah dikurangi
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${track.title} berhasil dibeli! 🎉'), backgroundColor: AppTheme.darkTeal));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membeli musik. Coba lagi.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('XP Shop'), centerTitle: false, backgroundColor: AppTheme.bg, elevation: 0),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SALDO XP ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.star, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('XP Kamu', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('$xp XP', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- SECTION FRAME AVATAR ---
            Text('Frame Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
            const SizedBox(height: 6),
            Text('Beli frame keren untuk mempercantik profilmu', style: TextStyle(fontSize: 13, color: AppTheme.txtGrey)),
            const SizedBox(height: 20),
            ...avatarFrames.map((frame) {
              final owned = ownedFrames.contains(frame.id);
              final equipped = equippedFrame == frame.id;
              return _FrameCard(
                frame: frame,
                owned: owned,
                equipped: equipped,
                canAfford: xp >= frame.price,
                onBuy: () => _buyFrame(frame),
                onEquip: () => _equipFrame(frame),
              );
            }).toList(),

            const SizedBox(height: 32),

            // --- SECTION MUSIK FOKUS ---
            Text('Musik Fokus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
            const SizedBox(height: 6),
            Text('Beli musik untuk menemani sesi fokusmu', style: TextStyle(fontSize: 13, color: AppTheme.txtGrey)),
            const SizedBox(height: 20),
            ...MusicService.instance.playlist.asMap().entries.map((entry) {
              final index = entry.key;
              final track = entry.value;
              final owned = MusicService.instance.isTrackOwned(track.title) || track.price == 0;

              return _MusicCard(
                track: track,
                owned: owned,
                canAfford: xp >= track.price,
                onBuy: () => _buyMusic(index, track),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// ================= WIDGET FRAME CARD =================
class _FrameCard extends StatelessWidget {
  final AvatarFrame frame;
  final bool owned;
  final bool equipped;
  final bool canAfford;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  const _FrameCard({required this.frame, required this.owned, required this.equipped, required this.canAfford, required this.onBuy, required this.onEquip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: equipped ? AppTheme.primary : AppTheme.border, width: 1.5),
      ),
      child: Row(
        children: [
          FramedAvatar(initial: 'A', frame: frame, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(frame.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.txt)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(frame.price == 0 ? 'Gratis' : '${frame.price} XP', style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (equipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text('Dipakai', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            )
          else if (owned)
            ElevatedButton(
              onPressed: onEquip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Pakai', style: TextStyle(fontSize: 13)),
            )
          else
            ElevatedButton(
              onPressed: canAfford ? onBuy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? AppTheme.accent : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Beli', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ================= WIDGET MUSIC CARD (BARU) =================
class _MusicCard extends StatelessWidget {
  final MusicTrack track;
  final bool owned;
  final bool canAfford;
  final VoidCallback onBuy;

  const _MusicCard({
    required this.track,
    required this.owned,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: Row(
        children: [
          // Icon Musik
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: track.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(track.icon, color: track.color, size: 30),
          ),
          const SizedBox(width: 16),

          // Info Musik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.txt)),
                const SizedBox(height: 4),
                Text(track.artist, style: TextStyle(fontSize: 13, color: AppTheme.txtGrey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      track.price == 0 ? 'Gratis' : '${track.price} XP',
                      style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol Aksi
          if (owned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                track.price == 0 ? 'Gratis' : 'Dimiliki',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            )
          else
            ElevatedButton(
              onPressed: canAfford ? onBuy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? AppTheme.accent : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Beli', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}