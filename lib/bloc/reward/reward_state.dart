abstract class RewardState {
  final int coins;
  final DateTime? lastScratchTime;
  final int scratchCount;

  RewardState(this.coins, {this.lastScratchTime, this.scratchCount = 1});

  // Check if the user can scratch
  bool canScratch() {
    if (lastScratchTime == null || scratchCount > 0) {
      return true; // Allow scratching if first time or scratch count is available
    }
    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastScratchTime!);
    return difference.inHours >= 1; // Allows scratch only after 1 minute
  }

  // Remaining time for the next scratch
  String remainingTime() {
    if (lastScratchTime == null || scratchCount > 0) {
      return "Scratch card is available now!";
    }
    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastScratchTime!);

    // If the user can scratch (1 minute has passed)
    if (difference.inHours >= 1) {
      return "Scratch card is available now!";
    }

    // Calculate remaining time
    final remainingMinutes = 60 - difference.inMinutes % 60;
    final remainingSeconds = 60 - difference.inSeconds % 60;
    return "Next scratch: $remainingMinutes min(s) $remainingSeconds sec(s)";
  }

  // Method to decrease scratch count
  RewardState scratch() {
    return RewardUpdated(
      coins,
      DateTime.now(),
      scratchCount: scratchCount > 0 ? scratchCount - 1 : 0,
    );
  }
}

class RewardInitial extends RewardState {
  RewardInitial()
      : super(1000, scratchCount: 1); // Initial coins and scratch count
}

class RewardUpdated extends RewardState {
  RewardUpdated(int coins, DateTime? lastScratchTime, {int scratchCount = 1})
      : super(coins,
            lastScratchTime: lastScratchTime, scratchCount: scratchCount);
}
