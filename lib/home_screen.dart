
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'scratch_card_widget.dart';
import 'store_screen.dart';
import 'history_screen.dart';
import 'bloc/reward/reward_bloc.dart';
import 'bloc/reward/reward_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward App')),
      body: BlocBuilder<RewardBloc, RewardState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Current Coin Balance: ${state.coins}',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                const ScratchCardWidget(),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StoreScreen()),
                  ),
                  child: const Text('Go to Store'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()),
                  ),
                  child: const Text('View History'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
