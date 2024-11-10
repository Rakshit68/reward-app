import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:reward_app/bloc/reward/reward_bloc.dart';
import 'package:reward_app/bloc/reward/reward_event.dart';
import 'package:reward_app/bloc/reward/reward_state.dart';

void main() {
  group('Coin Balance Tests', () {
    late RewardBloc rewardBloc;

    setUp(() {
      rewardBloc = RewardBloc();
    });

    tearDown(() {
      rewardBloc.close();
    });

    blocTest<RewardBloc, RewardState>(
      'should correctly update coin balance on scratch',
      build: () => rewardBloc,
      act: (bloc) {
        bloc.add(ScratchCardEvent(150)); // Scratch reward
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 150),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should correctly update coin balance on redemption',
      build: () => rewardBloc,
      seed: () => RewardUpdated(1000, DateTime.now()), // User has 1000 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(300)); // Item cost
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 700),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not deduct coins when balance is zero and redemption is triggered',
      build: () => rewardBloc,
      seed: () => RewardUpdated(0, DateTime.now()), // User has 0 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(300)); // Item cost
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 0),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should restrict scratch card interaction to one per hour',
      build: () => rewardBloc,
      seed: () => RewardUpdated(0, DateTime.now()), // User can scratch
      act: (bloc) async {
        bloc.add(ScratchCardEvent(150)); // First scratch
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(ScratchCardEvent(150)); // Try another scratch within the hour
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 150),
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 150),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not redeem item if there are insufficient coins',
      build: () => rewardBloc,
      seed: () => RewardUpdated(100, DateTime.now()), // User has 100 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(
            200)); // Item cost is higher than the current coin balance
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 100),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not allow coins to exceed max limit of 10000',
      build: () => rewardBloc,
      seed: () => RewardUpdated(9900, DateTime.now()), // User has 9900 coins
      act: (bloc) {
        bloc.add(ScratchCardEvent(200)); // Adding 200 coins
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 10000),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not allow coin balance to go below zero',
      build: () => rewardBloc,
      seed: () => RewardUpdated(100, DateTime.now()), // User has 100 coins
      act: (bloc) {
        bloc.add(ScratchCardEvent(-200)); // Trying to subtract 200 coins
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 0),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should correctly process redemption after scratching',
      build: () => rewardBloc,
      seed: () => RewardUpdated(500, DateTime.now()), // User has 500 coins
      act: (bloc) async {
        bloc.add(ScratchCardEvent(200)); // First scratch event
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(RedeemItemEvent(300)); // Now redeem
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 700),
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 400),
      ],
    );
  });
}
