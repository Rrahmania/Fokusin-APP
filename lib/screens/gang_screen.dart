import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'gang_timer_screen.dart';

class GangScreen extends StatefulWidget {
  const GangScreen({super.key});

  @override
  State<GangScreen> createState() => _GangScreenState();
}

class GangData {
  String name;
  String description;
  String purpose;
  String leader;
  int target;
  int completed;
  int focusDuration;
  List<String> members;
  List<String> pendingMembers;
  List<String> friends;

  GangData({
    required this.name,
    required this.description,
    required this.purpose,
    required this.leader,
    this.target = 10,
    this.completed = 0,
    this.focusDuration = 25,
    List<String>? members,
    List<String>? pendingMembers,
    List<String>? friends,
  })  : members = members ?? [],
        pendingMembers = pendingMembers ?? [],
        friends = friends ?? [];
}

class _GangScreenState extends State<GangScreen> {
  final String currentUser = 'Rahmania';

  late final List<GangData> gangs = [
    GangData(name: 'Focus Squad', description: 'Belajar bersama agar lebih konsisten.', purpose: 'Belajar', leader: 'Rahmania', members: ['Rahmania', 'Andina', 'Fathur', 'Rahma'], friends: ['Andina', 'Fathur', 'Rahma'], completed: 6, target: 10, focusDuration: 25, pendingMembers: ['Dina']),
    GangData(name: 'Productivity Club', description: 'Saling mendukung untuk menyelesaikan pekerjaan.', purpose: 'Bekerja', leader: 'Andina', members: ['Andina', 'Rahmania'], friends: ['Andina'], completed: 3, target: 8, focusDuration: 45),
  ];

  final List<String> availableFriends = ['Andina', 'Fathur', 'Rahma', 'Dina', 'Budi', 'Salsa'];
  final Set<String> sentRequests = {};
  int selectedTab = 0;

  void createGang() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Buat Gang Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Nama Gang',
                        hintText: 'Contoh: Study Squad',
                        prefixIcon: Icon(Icons.groups)
                    )
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        hintText: 'Apa tujuan Gang ini?',
                        prefixIcon: Icon(Icons.description)
                    )
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sebagai pembuat Gang, kamu otomatis menjadi Leader. Waktu fokus dapat diatur nanti.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Gang wajib diisi.')));
                  return;
                }
                final exists = gangs.any((gang) => gang.name.toLowerCase() == name.toLowerCase());
                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Gang sudah digunakan.')));
                  return;
                }
                setState(() {
                  gangs.insert(0, GangData(
                      name: name,
                      description: descriptionController.text.trim().isEmpty ? 'Komunitas fokus bersama.' : descriptionController.text.trim(),
                      purpose: 'Belajar',
                      leader: currentUser,
                      target: 10,
                      focusDuration: 25,
                      members: [currentUser]
                  ));
                  selectedTab = 0;
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gang berhasil dibuat! Kamu adalah Leader 🎉')));
              },
              child: const Text('Buat Gang'),
            ),
          ],
        );
      },
    );
  }

  void addFriend(GangData gang) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Teman'),
          content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Username teman', hintText: 'Contoh: Salsa', prefixIcon: Icon(Icons.person_add_alt_1))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final username = controller.text.trim();
                if (username.isEmpty) return;
                if (username.toLowerCase() == currentUser.toLowerCase()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kamu tidak bisa menambahkan diri sendiri.')));
                  return;
                }
                if (gang.members.any((member) => member.toLowerCase() == username.toLowerCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teman sudah menjadi anggota Gang.')));
                  return;
                }
                if (!availableFriends.any((friend) => friend.toLowerCase() == username.toLowerCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username tidak ditemukan pada daftar demo.')));
                  return;
                }
                setState(() {
                  if (!gang.friends.contains(username)) gang.friends.add(username);
                  if (!gang.pendingMembers.contains(username)) gang.pendingMembers.add(username);
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permintaan $username masuk ke daftar persetujuan Leader.')));
              },
              child: const Text('Kirim Permintaan'),
            ),
          ],
        );
      },
    );
  }

  void requestToJoin(GangData gang) {
    if (gang.members.contains(currentUser)) return;
    if (sentRequests.contains(gang.name)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permintaan kamu sudah dikirim.')));
      return;
    }
    setState(() {
      sentRequests.add(gang.name);
      gang.pendingMembers.add(currentUser);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permintaan bergabung ke ${gang.name} dikirim ke Leader.')));
  }

  bool isLeader(GangData gang) => gang.leader == currentUser;

  void approveMember(GangData gang, String member) {
    if (!isLeader(gang)) return;
    setState(() {
      gang.pendingMembers.remove(member);
      if (!gang.members.contains(member)) gang.members.add(member);
      sentRequests.remove(gang.name);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$member sekarang menjadi anggota Gang.')));
  }

  void rejectMember(GangData gang, String member) {
    if (!isLeader(gang)) return;
    setState(() {
      gang.pendingMembers.remove(member);
      sentRequests.remove(gang.name);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permintaan $member ditolak.')));
  }

  void removeMember(GangData gang, String member) {
    if (!isLeader(gang) || member == gang.leader) return;
    setState(() {
      gang.members.remove(member);
      gang.friends.remove(member);
    });
  }

  void deleteGang(GangData gang) {
    if (!isLeader(gang)) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Gang?'),
        content: Text('Gang "${gang.name}" akan dihapus dari daftar demo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() => gangs.remove(gang));
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void editFocusDuration(GangData gang, StateSetter setSheetState) {
    final durationController = TextEditingController(text: gang.focusDuration.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Atur Waktu Fokus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Masukkan durasi fokus (dalam menit):'),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Durasi (Menit)',
                  hintText: 'Contoh: 25',
                  prefixIcon: Icon(Icons.timer),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final newDuration = int.tryParse(durationController.text);
                // VALIDASI: Minimal 1 menit, Maksimal 1440 menit (24 jam)
                if (newDuration != null && newDuration > 0 && newDuration <= 1440) {
                  setState(() => gang.focusDuration = newDuration);
                  setSheetState(() {});
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan angka antara 1 - 1440 menit.'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void openGang(GangData gang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void refreshSheet(VoidCallback action) {
              setState(action);
              setSheetState(() {});
            }
            return SafeArea(
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.8,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: AppTheme.txtGrey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(5)))),
                      const SizedBox(height: 24),
                      Text(gang.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                      const SizedBox(height: 8),
                      Text(gang.description, style: TextStyle(color: AppTheme.txtGrey)),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border, width: 1.5)
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Waktu Fokus: ${gang.focusDuration} Menit', style: TextStyle(color: AppTheme.txt, fontWeight: FontWeight.w600)),
                            ),
                            if (isLeader(gang))
                              IconButton(
                                onPressed: () => editFocusDuration(gang, setSheetState),
                                icon: Icon(Icons.edit, color: AppTheme.primary, size: 20),
                                tooltip: 'Atur Waktu',
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (gang.members.contains(currentUser)) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => GangTimerScreen(
                                    gangName: gang.name,
                                    durationMinutes: gang.focusDuration,
                                  )
                              ));
                            },
                            icon: const Icon(Icons.play_circle_fill),
                            label: const Text('Mulai Gang Focus'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      LinearProgressIndicator(value: gang.target == 0 ? 0 : (gang.completed / gang.target).clamp(0.0, 1.0), minHeight: 8, color: AppTheme.primary, backgroundColor: AppTheme.border, borderRadius: BorderRadius.circular(8)),
                      const SizedBox(height: 8),
                      Text('Target harian: ${gang.completed}/${gang.target} sesi', style: TextStyle(color: AppTheme.txtGrey)),
                      const SizedBox(height: 24),
                      if (isLeader(gang)) ...[
                        Text('Permintaan Bergabung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                        const SizedBox(height: 12),
                        if (gang.pendingMembers.isEmpty)
                          Text('Belum ada permintaan baru.', style: TextStyle(color: AppTheme.txt))
                        else
                          ...gang.pendingMembers.toList().map(
                                (member) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(backgroundColor: AppTheme.lightTeal, child: Text(member[0].toUpperCase(), style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
                              title: Text(member, style: TextStyle(color: AppTheme.txt, fontWeight: FontWeight.bold)),
                              subtitle: Text('Menunggu persetujuan', style: TextStyle(color: AppTheme.txtGrey)),
                              trailing: Wrap(
                                spacing: 2,
                                children: [
                                  IconButton(tooltip: 'Terima', onPressed: () => refreshSheet(() => approveMember(gang, member)), icon: const Icon(Icons.check_circle, color: Colors.green)),
                                  IconButton(tooltip: 'Tolak', onPressed: () => refreshSheet(() => rejectMember(gang, member)), icon: const Icon(Icons.cancel, color: Colors.red)),
                                ],
                              ),
                            ),
                          ),
                        const Divider(height: 32),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Anggota', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                          if (isLeader(gang))
                            TextButton.icon(onPressed: () { Navigator.pop(sheetContext); addFriend(gang); }, icon: const Icon(Icons.person_add), label: const Text('Tambah')),
                        ],
                      ),
                      ...gang.members.map(
                            (member) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: AppTheme.lightTeal, child: Text(member[0].toUpperCase(), style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
                          title: Text(member, style: TextStyle(color: AppTheme.txt, fontWeight: FontWeight.bold)),
                          subtitle: Text(member == gang.leader ? 'Leader' : 'Anggota', style: TextStyle(color: AppTheme.txtGrey)),
                          trailing: member == gang.leader
                              ? Icon(Icons.shield, color: AppTheme.primary)
                              : isLeader(gang)
                              ? IconButton(tooltip: 'Hapus anggota', onPressed: () => refreshSheet(() => removeMember(gang, member)), icon: const Icon(Icons.person_remove, color: Colors.red))
                              : null,
                        ),
                      ),
                      if (isLeader(gang)) ...[
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () { Navigator.pop(sheetContext); deleteGang(gang); },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hapus Gang'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red, width: 1.5), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myGangs = gangs.where((gang) => gang.members.contains(currentUser)).toList();
    final discoverGangs = gangs.where((gang) => !gang.members.contains(currentUser)).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pomodoro Gang', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                        const SizedBox(height: 6),
                        Text('Focus better, together.', style: TextStyle(color: AppTheme.txtGrey)),
                      ],
                    ),
                  ),
                  Icon(Icons.groups_rounded, size: 35, color: AppTheme.primary),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Apa itu Pomodoro Gang?', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Komunitas fokus bersama teman. Buat target, pantau progres Pomodoro, dan saling memotivasi. Leader bisa mengatur durasi timer untuk seluruh anggota.', style: TextStyle(color: AppTheme.primary, height: 1.5, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(onPressed: createGang, icon: const Icon(Icons.add), label: const Text('Create New Gang')),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _tabButton('My Gangs (${myGangs.length})', 0)),
                  const SizedBox(width: 12),
                  Expanded(child: _tabButton('Discover', 1)),
                ],
              ),
              const SizedBox(height: 20),
              if (selectedTab == 0) ...[
                if (myGangs.isEmpty)
                  _emptyState('Belum punya Gang', 'Buat Gang baru atau cari Gang untuk diikuti.')
                else
                  ...myGangs.map((gang) => _gangCard(gang, mine: true)),
              ] else ...[
                if (discoverGangs.isEmpty)
                  _emptyState('Tidak ada Gang baru', 'Semua Gang demo sudah kamu ikuti.')
                else
                  ...discoverGangs.map((gang) => _gangCard(gang, mine: false)),
              ],
              const SizedBox(height: 32),
              Text('Peran dalam Gang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
              const SizedBox(height: 12),
              _roleInfo(Icons.shield, 'Leader', 'Membuat Gang, mengatur waktu fokus (timer), mengelola anggota, serta menerima atau menolak permintaan masuk.'),
              _roleInfo(Icons.person, 'Member', 'Mengikuti target Pomodoro dan durasi timer yang telah diatur oleh Leader.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final active = selectedTab == index;
    return OutlinedButton(
      onPressed: () => setState(() => selectedTab = index),
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? AppTheme.primary : AppTheme.card,
        foregroundColor: active ? Colors.white : AppTheme.txt,
        side: BorderSide(color: active ? AppTheme.primary : AppTheme.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(0, 48),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _gangCard(GangData gang, {required bool mine}) {
    final leader = isLeader(gang);
    final progress = gang.target == 0 ? 0.0 : (gang.completed / gang.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.groups, color: AppTheme.primary, size: 27)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gang.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                    const SizedBox(height: 4),
                    Text('${gang.members.length} anggota • ${gang.purpose} • ${gang.focusDuration}m', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                  ],
                ),
              ),
              if (mine) IconButton(onPressed: () => openGang(gang), icon: Icon(Icons.more_horiz, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(gang.description, style: TextStyle(fontSize: 13, color: AppTheme.txtGrey, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Pomodoro Goal', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
              Text('${gang.completed}/${gang.target}', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 8, color: AppTheme.primary, backgroundColor: AppTheme.border)),
          const SizedBox(height: 16),
          if (mine) ...[
            Row(
              children: [
                Icon(leader ? Icons.shield : Icons.person, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(leader ? 'Kamu adalah Leader' : 'Leader: ${gang.leader}', style: TextStyle(color: AppTheme.txtGrey, fontSize: 12))),
                if (leader && gang.pendingMembers.isNotEmpty)
                  TextButton(onPressed: () => openGang(gang), child: Text('${gang.pendingMembers.length} permintaan', style: TextStyle(color: AppTheme.primary))),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: () => openGang(gang), child: const Text('Manage / View Gang'))),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => requestToJoin(gang),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: BorderSide(color: AppTheme.primary, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(sentRequests.contains(gang.name) ? 'Request Sent' : 'Request to Join'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState(String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 48, color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt, fontSize: 16)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.txtGrey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _roleInfo(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12, color: AppTheme.txtGrey, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}