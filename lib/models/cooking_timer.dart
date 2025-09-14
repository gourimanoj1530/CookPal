class CookingTimer {
  final int id;
  final String name;
  final int durationInSeconds;
  final DateTime startTime;
  bool isRunning;
  bool isCompleted;

  CookingTimer({
    required this.id,
    required this.name,
    required this.durationInSeconds,
    required this.startTime,
    this.isRunning = false,
    this.isCompleted = false,
  });

  int get remainingSeconds {
    if (isCompleted) return 0;

    final elapsed = DateTime.now().difference(startTime).inSeconds;
    final remaining = durationInSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  String get formattedTime {
    int seconds = remainingSeconds;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;

    seconds = seconds % 60;
    minutes = minutes % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  double get progress {
    if (durationInSeconds == 0) return 1.0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    final progress = elapsed / durationInSeconds;
    return progress.clamp(0.0, 1.0);
  }
}