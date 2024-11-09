class TransactionState {
  final List<Map<String, dynamic>> transactions;

  const TransactionState(this.transactions);
}

class TransactionInitial extends TransactionState {
  const TransactionInitial() : super(const []);
}
