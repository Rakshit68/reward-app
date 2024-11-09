import 'package:flutter_bloc/flutter_bloc.dart';
import 'reward_event.dart';
import 'reward_state.dart';

class RewardBloc extends Bloc<RewardEvent, RewardState> {
  RewardBloc() : super(RewardInitial()) {
    on<ScratchCardEvent>((event, emit) {
      if (state.canScratch()) {
        final newBalance = state.coins + event.reward;
        final updatedState = RewardUpdated(
          newBalance,
          DateTime.now()

        );
        emit(updatedState);
      }
      
    });

    on<RedeemItemEvent>((event, emit) {
      if (state.coins >= event.cost) {
        final newBalance = state.coins - event.cost;
        emit(RewardUpdated(newBalance, state.lastScratchTime));
      }
    });
  }
}
