import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/transaction/transaction_bloc.dart';
import 'bloc/transaction/transaction_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              final transaction = state.transactions[index];
              final sign = transaction['amount'] > 0 ? '+' : '';
              return ListTile(
                title: Text(transaction['type']),
                subtitle: Text(
                  '$sign${transaction['amount']} Coins on ${transaction['date']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
