import 'package:flutter/material.dart';

class Transaction {
  final String type;
  final int amount;
  final DateTime date;

  Transaction({required this.type, required this.amount, required this.date});
}

class TransactionProvider with ChangeNotifier {
  int _coinBalance = 1000;
  List<Transaction> _transactions = [];

  int get coinBalance => _coinBalance;
  List<Transaction> get transactions => _transactions;

  void addCoins(int coins) {
    _coinBalance += coins;
    _transactions.add(
      Transaction(
        type: 'Scratch Reward',
        amount: coins,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void redeemItem(int cost, String itemName) {
    if (_coinBalance >= cost) {
      _coinBalance -= cost;
      _transactions.add(
        Transaction(
          type: 'Redeemed Item: $itemName',
          amount: -cost,
          date: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }
}
