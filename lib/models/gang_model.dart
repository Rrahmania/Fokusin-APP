class GangMember {
  String name;
  String status;
  bool isFocusing;

  GangMember({
    required this.name,
    required this.status,
    required this.isFocusing,
  });
}

class GangModel {
  String name;
  String description;
  List<GangMember> members;
  int completedPomodoro;
  int targetPomodoro;

  GangModel({
    required this.name,
    required this.description,
    required this.members,
    required this.completedPomodoro,
    required this.targetPomodoro,
  });

  double get progress {
    if (targetPomodoro == 0) return 0;
    return completedPomodoro / targetPomodoro;
  }

  void addPomodoro() {
    if (completedPomodoro < targetPomodoro) completedPomodoro++;
  }
}