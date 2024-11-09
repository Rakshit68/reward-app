import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(const TransactionInitial()) {
    on<AddTransactionEvent>((event, emit) {
      final updatedTransactions = List<Map<String, dynamic>>.from(
          state.transactions)
        ..add({'type': event.type, 'amount': event.amount, 'date': event.date,});
      emit(TransactionState(updatedTransactions));
    });
  }
}