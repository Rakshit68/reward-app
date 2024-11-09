import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/reward/reward_bloc.dart';
import 'bloc/reward/reward_event.dart';
import 'bloc/reward/reward_state.dart';
import 'bloc/transaction/transaction_bloc.dart';
import 'bloc/transaction/transaction_event.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defining the items available in the store
    final List<Map<String, dynamic>> items = [
      {'name': 'Myntra Discount Coupon', 'cost': 300},
      {'name': 'Flipkart Gift Card', 'cost': 700},
      {'name': 'D-Mart Shopping Voucher', 'cost': 500},
      {'name': 'Play Store Credits', 'cost': 200},
      {'name': 'Amazon Prime Subscription', 'cost': 1000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: BlocBuilder<RewardBloc, RewardState>(
        builder: (context, rewardState) {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final String itemName = item['name'] as String;
              final int itemCost = item['cost'] as int;

              return ListTile(
                title: Text(itemName),
                subtitle: Text('$itemCost Coins'),
                trailing: ElevatedButton(
                  onPressed: rewardState.coins >= itemCost
                      ? () {
                          context
                              .read<RewardBloc>()
                              .add(RedeemItemEvent(itemCost));
                          context.read<TransactionBloc>().add(
                                AddTransactionEvent(
                                  'Redeemed $itemName',
                                  -itemCost,
                                  DateTime.now(),
                                ),
                              );
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Congratulations!"),
                                content: Text(
                                  "You have successfully redeemed $itemName!\n"
                                  "Current Coin Balance: ${rewardState.coins - itemCost}",
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); 
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      : () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Insufficient Funds"),
                                content: Text(
                                  "You do not have enough coins to redeem this item.\n"
                                  "Current Coin Balance: ${rewardState.coins}",
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); 
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                  child: const Text('Redeem'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
