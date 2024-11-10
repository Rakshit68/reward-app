import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:reward_app/bloc/reward/reward_bloc.dart';
import 'package:reward_app/bloc/reward/reward_event.dart';
import 'package:reward_app/bloc/reward/reward_state.dart';

void main() {
  group('Redemption Process Tests', () {
    late RewardBloc rewardBloc;

    setUp(() {
      rewardBloc = RewardBloc();
    });

    tearDown(() {
      rewardBloc.close();
    });

    blocTest<RewardBloc, RewardState>(
      'should successfully redeem an item if user has enough coins',
      build: () => rewardBloc,
      seed: () => RewardUpdated(500, DateTime.now()), // User has 500 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(300)); // Item cost
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 200),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not redeem item if user has insufficient coins',
      build: () => rewardBloc,
      seed: () => RewardUpdated(100, DateTime.now()), // User has 100 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(200)); // Item cost more than available coins
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 100),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should correctly process redemption after scratch reward',
      build: () => rewardBloc,
      seed: () => RewardUpdated(500, DateTime.now()), // User has 500 coins
      act: (bloc) async {
        bloc.add(ScratchCardEvent(300)); // Scratch reward
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(RedeemItemEvent(500)); // Redeem item with cost 500
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 800),
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 300),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not redeem an item if item cost is zero',
      build: () => rewardBloc,
      seed: () => RewardUpdated(500, DateTime.now()), // User has 500 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(0)); // Item cost is zero
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 500),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not redeem an item if item cost is negative',
      build: () => rewardBloc,
      seed: () => RewardUpdated(500, DateTime.now()), // User has 500 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(-100)); // Item cost is negative
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 500),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should redeem item correctly when user has exactly enough coins',
      build: () => rewardBloc,
      seed: () => RewardUpdated(500, DateTime.now()), // User has 500 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(500)); // Item cost equals user's balance
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 0),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should allow multiple redemptions if user has enough coins',
      build: () => rewardBloc,
      seed: () => RewardUpdated(1000, DateTime.now()), // User has 1000 coins
      act: (bloc) async {
        bloc.add(RedeemItemEvent(300)); 
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(RedeemItemEvent(200)); // Second item cost
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 700),
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 500),
      ],
    );

    blocTest<RewardBloc, RewardState>(
      'should not allow redemption when user has insufficient coins after redemption',
      build: () => rewardBloc,
      seed: () => RewardUpdated(100, DateTime.now()), // User has 100 coins
      act: (bloc) {
        bloc.add(RedeemItemEvent(200)); // Item cost more than available coins
      },
      expect: () => [
        isA<RewardUpdated>().having((state) => state.coins, 'coins', 100),
      ],
    );
  });
}
