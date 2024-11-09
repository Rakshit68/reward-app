abstract class RewardState {
  final int coins;
  final DateTime? lastScratchTime;

  RewardState(this.coins, {this.lastScratchTime});

  //if the user can scratch
  bool canScratch() {
    if (lastScratchTime == null) {
      return true; //First time scratching, allow
    }
    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastScratchTime!);
    return difference.inHours >= 1; // Allows scratch only after 1 hour
  }

  //remaining time for next scratch
  String remainingTime() {
    if (lastScratchTime == null) {
      return "Scratch card is avilable now!";
    }
    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastScratchTime!);

    // If user can scratch (more than 1 hour passed)
    if (difference.inHours >= 1) {
      return "Scratch card is avilable now!";
    }

    // remaining time until next scratch (1 hour)
    final remainingMinutes = 59 - difference.inMinutes % 60;
    final remainingSeconds = 60 - difference.inSeconds % 60;

    return "Next scratch: $remainingMinutes minute(s) and $remainingSeconds second(s)";
  }
}

class RewardInitial extends RewardState {
  RewardInitial() : super(1000); // Initial coins
}

class RewardUpdated extends RewardState {
  RewardUpdated(int coins, DateTime? lastScratchTime)
      : super(coins, lastScratchTime: lastScratchTime);
}
