abstract class TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final String type;
  final int amount;
  final DateTime date;

  AddTransactionEvent(this.type, this.amount, this.date);
}
