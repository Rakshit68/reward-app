import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_screen.dart';
import 'bloc/reward/reward_bloc.dart';
import 'bloc/transaction/transaction_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RewardBloc()),
        BlocProvider(create: (_) => TransactionBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Reward App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
      ),
    );
  }
}
