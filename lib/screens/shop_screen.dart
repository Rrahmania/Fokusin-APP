import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/shop_model.dart';
import '../services/storage_service.dart';
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

  Future<void> _buyFrame(AvatarFrame frame) async {
    if (xp < frame.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('XP kamu tidak cukup! Butuh ${frame.price} XP.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Beli ${frame.name}?'),
        content: Text('Gunakan ${frame.price} XP untuk membeli frame ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${frame.name} berhasil dibeli! 🎉'),
        backgroundColor: AppTheme.darkTeal,
      ),
    );
  }

  Future<void> _equipFrame(AvatarFrame frame) async {
    await StorageService.saveEquippedFrame(frame.id);
    if (!mounted) return;
    setState(() => equippedFrame = frame.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${frame.name} dipakai! ✨'),
        backgroundColor: AppTheme.darkTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('XP Shop'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryTeal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.star,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('XP Kamu',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('$xp XP',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Text('Frame Avatar',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.txt)),
            const SizedBox(height: 4),
            Text('Beli frame keren untuk mempercantik profilmu',
                style: TextStyle(fontSize: 13, color: AppTheme.txtGrey)),
            const SizedBox(height: 15),

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
          ],
        ),
      ),
    );
  }
}

class _FrameCard extends StatelessWidget {
  final AvatarFrame frame;
  final bool owned;
  final bool equipped;
  final bool canAfford;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  const _FrameCard({
    required this.frame,
    required this.owned,
    required this.equipped,
    required this.canAfford,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: equipped
            ? Border.all(color: AppTheme.primaryTeal, width: 2)
            : null,
      ),
      child: Row(
        children: [
          FramedAvatar(initial: 'A', frame: frame, size: 60),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(frame.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.txt)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppTheme.primaryTeal),
                    const SizedBox(width: 4),
                    Text(frame.price == 0 ? 'Gratis' : '${frame.price} XP',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (equipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle,
                      size: 16, color: AppTheme.primaryTeal),
                  SizedBox(width: 4),
                  Text('Dipakai',
                      style: TextStyle(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            )
          else if (owned)
            ElevatedButton(
              onPressed: onEquip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Pakai', style: TextStyle(fontSize: 13)),
            )
          else
            ElevatedButton(
              onPressed: canAfford ? onBuy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? Colors.orange : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Beli', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}