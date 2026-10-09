
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    List<String>? members,
    List<String>? pendingMembers,
    List<String>? friends,
  })  : members = members ?? [],
        pendingMembers = pendingMembers ?? [],
        friends = friends ?? [];
}

class _GangScreenState extends State<GangScreen> {
  // Simulasi user yang sedang login.
  final String currentUser = 'Rahmania';

  late final List<GangData> gangs = [
    GangData(
      name: 'Focus Squad',
      description: 'Belajar bersama agar lebih konsisten.',
      purpose: 'Belajar',
      leader: 'Rahmania',
      members: ['Rahmania', 'Andina', 'Fathur', 'Rahma'],
      friends: ['Andina', 'Fathur', 'Rahma'],
      completed: 6,
      target: 10,
      pendingMembers: ['Dina'],
    ),
    GangData(
      name: 'Productivity Club',
      description: 'Saling mendukung untuk menyelesaikan pekerjaan.',
      purpose: 'Bekerja',
      leader: 'Andina',
      members: ['Andina', 'Rahmania'],
      friends: ['Andina'],
      completed: 3,
      target: 8,
    ),
  ];

  final List<String> availableFriends = [
    'Andina',
    'Fathur',
    'Rahma',
    'Dina',
    'Budi',
    'Salsa',
  ];

  final Set<String> sentRequests = {};
  int selectedTab = 0;

  Color get teal => AppTheme.primaryTeal;
  Color get darkTeal => AppTheme.darkTeal;

  // ============================================================
  // CREATE GANG
  // ============================================================

  void createGang() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String purpose = 'Belajar';
    int target = 10;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                        prefixIcon: Icon(Icons.groups),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        hintText: 'Apa tujuan Gang ini?',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: purpose,
                      decoration: const InputDecoration(
                        labelText: 'Tujuan Gang',
                      ),
                      items: ['Belajar', 'Bekerja', 'Olahraga']
                          .map(
                            (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => purpose = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: target,
                      decoration: const InputDecoration(
                        labelText: 'Target Pomodoro harian',
                      ),
                      items: [4, 6, 8, 10, 12]
                          .map(
                            (value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value sesi'),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => target = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sebagai pembuat Gang, kamu otomatis menjadi Leader.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Nama Gang wajib diisi.'),
                        ),
                      );
                      return;
                    }

                    final exists = gangs.any(
                          (gang) =>
                      gang.name.toLowerCase() == name.toLowerCase(),
                    );

                    if (exists) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Nama Gang sudah digunakan.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      gangs.insert(
                        0,
                        GangData(
                          name: name,
                          description:
                          descriptionController.text.trim().isEmpty
                              ? 'Komunitas fokus bersama.'
                              : descriptionController.text.trim(),
                          purpose: purpose,
                          leader: currentUser,
                          target: target,
                          members: [currentUser],
                        ),
                      );
                      selectedTab = 0;
                    });

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Gang berhasil dibuat! Kamu adalah Leader 🎉',
                        ),
                      ),
                    );
                  },
                  child: const Text('Buat Gang'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ADD FRIEND
  // ============================================================

  void addFriend(GangData gang) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Teman'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Username teman',
              hintText: 'Contoh: Salsa',
              prefixIcon: Icon(Icons.person_add_alt_1),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final username = controller.text.trim();

                if (username.isEmpty) return;

                if (username.toLowerCase() ==
                    currentUser.toLowerCase()) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Kamu tidak bisa menambahkan diri sendiri.'),
                    ),
                  );
                  return;
                }

                if (gang.members.any(
                      (member) =>
                  member.toLowerCase() == username.toLowerCase(),
                )) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Teman sudah menjadi anggota Gang.'),
                    ),
                  );
                  return;
                }

                if (!availableFriends.any(
                      (friend) =>
                  friend.toLowerCase() == username.toLowerCase(),
                )) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Username tidak ditemukan pada daftar demo.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (!gang.friends.contains(username)) {
                    gang.friends.add(username);
                  }

                  if (!gang.pendingMembers.contains(username)) {
                    gang.pendingMembers.add(username);
                  }
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Permintaan $username masuk ke daftar persetujuan Leader.',
                    ),
                  ),
                );
              },
              child: const Text('Kirim Permintaan'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DISCOVER GANG / REQUEST TO JOIN
  // ============================================================

  void requestToJoin(GangData gang) {
    if (gang.members.contains(currentUser)) return;

    if (sentRequests.contains(gang.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan kamu sudah dikirim.'),
        ),
      );
      return;
    }

    setState(() {
      sentRequests.add(gang.name);
      gang.pendingMembers.add(currentUser);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Permintaan bergabung ke ${gang.name} dikirim ke Leader.',
        ),
      ),
    );
  }

  // ============================================================
  // LEADER: APPROVE / REJECT
  // ============================================================

  bool isLeader(GangData gang) => gang.leader == currentUser;

  void approveMember(GangData gang, String member) {
    if (!isLeader(gang)) return;

    setState(() {
      gang.pendingMembers.remove(member);

      if (!gang.members.contains(member)) {
        gang.members.add(member);
      }

      sentRequests.remove(gang.name);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$member sekarang menjadi anggota Gang.')),
    );
  }

  void rejectMember(GangData gang, String member) {
    if (!isLeader(gang)) return;

    setState(() {
      gang.pendingMembers.remove(member);
      sentRequests.remove(gang.name);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Permintaan $member ditolak.')),
    );
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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => gangs.remove(gang));
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GANG DETAILS
  // ============================================================

  void openGang(GangData gang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        gang.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkTeal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(gang.description),
                      const SizedBox(height: 8),
                      Text('Tujuan: ${gang.purpose}'),
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: gang.target == 0
                            ? 0
                            : (gang.completed / gang.target).clamp(0.0, 1.0),
                        minHeight: 8,
                        color: teal,
                        backgroundColor: AppTheme.lightTeal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target harian: ${gang.completed}/${gang.target} sesi',
                      ),
                      const SizedBox(height: 18),
                      if (isLeader(gang)) ...[
                        const Text(
                          'Permintaan Bergabung',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (gang.pendingMembers.isEmpty)
                          const Text('Belum ada permintaan baru.')
                        else
                          ...gang.pendingMembers.toList().map(
                                (member) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.lightTeal,
                                child: Text(member[0].toUpperCase()),
                              ),
                              title: Text(member),
                              subtitle: const Text('Menunggu persetujuan'),
                              trailing: Wrap(
                                spacing: 2,
                                children: [
                                  IconButton(
                                    tooltip: 'Terima',
                                    onPressed: () => refreshSheet(
                                          () => approveMember(gang, member),
                                    ),
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Tolak',
                                    onPressed: () => refreshSheet(
                                          () => rejectMember(gang, member),
                                    ),
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const Divider(height: 28),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Anggota',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isLeader(gang))
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                addFriend(gang);
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Tambah'),
                            ),
                        ],
                      ),
                      ...gang.members.map(
                            (member) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.lightTeal,
                            child: Text(member[0].toUpperCase()),
                          ),
                          title: Text(member),
                          subtitle: Text(
                            member == gang.leader ? 'Leader' : 'Anggota',
                          ),
                          trailing: member == gang.leader
                              ? Icon(Icons.shield, color: teal)
                              : isLeader(gang)
                              ? IconButton(
                            tooltip: 'Hapus anggota',
                            onPressed: () => refreshSheet(
                                  () => removeMember(gang, member),
                            ),
                            icon: const Icon(
                              Icons.person_remove,
                              color: Colors.red,
                            ),
                          )
                              : null,
                        ),
                      ),
                      if (isLeader(gang)) ...[
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            deleteGang(gang);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hapus Gang'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
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

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final myGangs = gangs
        .where((gang) => gang.members.contains(currentUser))
        .toList();

    final discoverGangs = gangs
        .where((gang) => !gang.members.contains(currentUser))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pomodoro Gang',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: darkTeal,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Focus better, together.',
                          style: TextStyle(color: AppTheme.txtGrey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.groups_rounded, size: 35, color: teal),
                ],
              ),
              const SizedBox(height: 22),

              // PENJELASAN FITUR
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightTeal,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: darkTeal, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apa itu Pomodoro Gang?',
                            style: TextStyle(
                              color: darkTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Komunitas fokus bersama teman. Buat target, '
                                'pantau progres Pomodoro, dan saling memotivasi. '
                                'Leader menjaga agar anggota baru mendapat izin.',
                            style: TextStyle(
                              color: darkTeal,
                              height: 1.45,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CREATE GANG
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: createGang,
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Gang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // TABS
              Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      'My Gangs (${myGangs.length})',
                      0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _tabButton(
                      'Discover',
                      1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (selectedTab == 0) ...[
                if (myGangs.isEmpty)
                  _emptyState(
                    'Belum punya Gang',
                    'Buat Gang baru atau cari Gang untuk diikuti.',
                  )
                else
                  ...myGangs.map((gang) => _gangCard(gang, mine: true)),
              ] else ...[
                if (discoverGangs.isEmpty)
                  _emptyState(
                    'Tidak ada Gang baru',
                    'Semua Gang demo sudah kamu ikuti.',
                  )
                else
                  ...discoverGangs.map(
                        (gang) => _gangCard(gang, mine: false),
                  ),
              ],
              const SizedBox(height: 20),

              // KETERANGAN ROLE
              Text(
                'Peran dalam Gang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.txt,
                ),
              ),
              const SizedBox(height: 10),
              _roleInfo(
                Icons.shield,
                'Leader',
                'Membuat Gang, mengelola anggota, serta menerima atau menolak permintaan masuk.',
              ),
              _roleInfo(
                Icons.person,
                'Member',
                'Mengikuti target Pomodoro, melihat progres, dan berkolaborasi bersama anggota lain.',
              ),
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
        backgroundColor: active ? teal : AppTheme.card,
        foregroundColor: active ? Colors.white : darkTeal,
        side: BorderSide(color: active ? teal : AppTheme.lightTeal),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _gangCard(GangData gang, {required bool mine}) {
    final leader = isLeader(gang);
    final progress = gang.target == 0
        ? 0.0
        : (gang.completed / gang.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.lightTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.groups, color: darkTeal, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gang.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.txt,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${gang.members.length} anggota • ${gang.purpose}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.txtGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (mine)
                IconButton(
                  onPressed: () => openGang(gang),
                  icon: Icon(Icons.more_horiz, color: darkTeal),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            gang.description,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.txtGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Pomodoro Goal',
                style: TextStyle(fontSize: 12, color: AppTheme.txtGrey),
              ),
              Text(
                '${gang.completed}/${gang.target}',
                style: TextStyle(
                  color: teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: teal,
              backgroundColor: AppTheme.lightTeal,
            ),
          ),
          const SizedBox(height: 14),
          if (mine) ...[
            Row(
              children: [
                Icon(
                  leader ? Icons.shield : Icons.person,
                  color: teal,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    leader ? 'Kamu adalah Leader' : 'Leader: ${gang.leader}',
                    style: TextStyle(
                      color: AppTheme.txtGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (leader && gang.pendingMembers.isNotEmpty)
                  TextButton(
                    onPressed: () => openGang(gang),
                    child: Text(
                      '${gang.pendingMembers.length} permintaan',
                      style: TextStyle(color: teal),
                    ),
                  ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => openGang(gang),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Manage / View Gang'),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => requestToJoin(gang),
                child: Text(
                  sentRequests.contains(gang.name)
                      ? 'Request Sent'
                      : 'Request to Join',
                ),
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 42, color: teal),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.txtGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _roleInfo(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: teal, size: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.txt,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.txtGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
