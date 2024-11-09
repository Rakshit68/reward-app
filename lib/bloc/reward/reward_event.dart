abstract class RewardEvent {}

class ScratchCardEvent extends RewardEvent {
  final int reward;
  ScratchCardEvent(this.reward);
}

class RedeemItemEvent extends RewardEvent {
  final int cost;
  RedeemItemEvent(this.cost);
}
