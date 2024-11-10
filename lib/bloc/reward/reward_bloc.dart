import 'package:flutter_bloc/flutter_bloc.dart';
import 'reward_event.dart';
import 'reward_state.dart';

class RewardBloc extends Bloc<RewardEvent, RewardState> {
  RewardBloc() : super(RewardInitial()) {
    // Handle scratching the card
    on<ScratchCardEvent>((event, emit) {
      if (state.canScratch()) {
        final newBalance = state.coins + event.reward;

        // Deduct a scratch and update the last scratch time
        final updatedState = state.scratch(); // Use scratch() method
        emit(RewardUpdated(
          newBalance,
          updatedState.lastScratchTime,
          scratchCount: updatedState.scratchCount,
        ));
      }
    });

    // Handle redeeming items
    on<RedeemItemEvent>((event, emit) {
      if (state.coins >= event.cost) {
        final newBalance = state.coins - event.cost;
        emit(RewardUpdated(
          newBalance,
          state.lastScratchTime,
          scratchCount: state.scratchCount,
        ));
      }
    });

    // Handle manually using a scratch card
    on<ScratchCardUsedEvent>((event, emit) {
      if (state.scratchCount > 0) {
        final updatedState = state.scratch(); // Use scratch() method
        emit(RewardUpdated(
          state.coins,
          updatedState.lastScratchTime,
          scratchCount: updatedState.scratchCount,
        ));
      }
    });

    // Reset scratch card count after the cooldown period
    on<ResetScratchCardEvent>((event, emit) {
      emit(RewardUpdated(
        state.coins,
        state.lastScratchTime,
        scratchCount: 1, // Reset to 1 scratch available
      ));
    });
  }
}
