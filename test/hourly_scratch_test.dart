import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:reward_app/bloc/reward/reward_bloc.dart';
import 'package:reward_app/bloc/reward/reward_event.dart';
import 'package:reward_app/bloc/reward/reward_state.dart';

void main() {
  group('Hourly Scratch Tests', () {
    late RewardBloc rewardBloc;

    setUp(() {
      rewardBloc = RewardBloc();
    });

    tearDown(() {
      rewardBloc.close();
    });

    blocTest<RewardBloc, RewardState>(
      'should allow scratch after 1 hour',
      build: () => rewardBloc,
      seed: () => RewardUpdated(0, DateTime.now().subtract(Duration(hours: 1))),
      act: (bloc) {},
      verify: (bloc) {
        expect(bloc.state.canScratch(), true);
      },
    );

    blocTest<RewardBloc, RewardState>(
      'should not allow scratch before 1 hour',
      build: () => rewardBloc,
      seed: () =>
          RewardUpdated(0, DateTime.now().subtract(Duration(minutes: 30))),
      act: (bloc) {},
      verify: (bloc) {
        expect(bloc.state.canScratch(), false);
      },
    );

    blocTest<RewardBloc, RewardState>(
      'should update coin balance after a successful scratch',
      build: () => rewardBloc,
      act: (bloc) {
        bloc.add(ScratchCardEvent(100)); // Scratch reward
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 100),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not allow scratch if user has already scratched in the last hour',
      build: () => rewardBloc,
      seed: () => RewardUpdated(1000, DateTime.now()), // User has 1000 coins
      act: (bloc) {},
      verify: (bloc) {
        expect(bloc.state.canScratch(), false);
      },
    );

    blocTest<RewardBloc, RewardState>(
      'should give reward after multiple valid scratch attempts',
      build: () => rewardBloc,
      seed: () => RewardUpdated(500,
          DateTime.now().subtract(Duration(hours: 1))), // User has 500 coins
      act: (bloc) async {
        bloc.add(ScratchCardEvent(150)); // First scratch
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.emit(RewardUpdated(
            bloc.state.coins, DateTime.now().subtract(Duration(hours: 1))));
        bloc.add(ScratchCardEvent(150)); // Second scratch after one hour
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 650),
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 800),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should update the last scratch time after a successful scratch',
      build: () => rewardBloc,
      seed: () => RewardUpdated(
          500, DateTime.now().subtract(Duration(hours: 1))), // 1 hour ago
      act: (bloc) {
        bloc.add(ScratchCardEvent(100)); // Scratch reward
      },
      verify: (bloc) {
        expect(
            bloc.state.lastScratchTime!
                .isAfter(DateTime.now().subtract(Duration(hours: 1))),
            true);
      },
    );

    blocTest<RewardBloc, RewardState>(
      'should not allow negative rewards on scratch',
      build: () => rewardBloc,
      seed: () => RewardUpdated(500, DateTime.now()), // User has 500 coins
      act: (bloc) {
        bloc.add(ScratchCardEvent(-100)); // Negative reward for scratch
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 500),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should allow scratch even with zero coins',
      build: () => rewardBloc,
      seed: () => RewardUpdated(0, DateTime.now()), // User has 0 coins
      act: (bloc) {
        bloc.add(ScratchCardEvent(200)); // Reward for scratch
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 200),
      ],
    );
  });
}
