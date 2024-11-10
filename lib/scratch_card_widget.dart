import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reward_app/bloc/transaction/transaction_event.dart';
import 'bloc/reward/reward_bloc.dart';
import 'bloc/reward/reward_event.dart';
import 'bloc/reward/reward_state.dart';
import 'bloc/transaction/transaction_bloc.dart';
import 'bloc/transaction/transaction_event.dart';
import 'dart:async';

class ScratchCardWidget extends StatefulWidget {
  const ScratchCardWidget({super.key});

  @override
  _ScratchCardWidgetState createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  List<Offset?> _scratchPoints = [];
  double _scratchProgress = 0.0;
  bool _isScratched = false;
  bool _isCardVisible = true;
  final GlobalKey _cardKey = GlobalKey();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoUpdate();
  }

  void _startAutoUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetScratchCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isScratched = false;
        _scratchPoints.clear();
        _isCardVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RewardBloc, RewardState>(
      builder: (context, state) {
        bool canScratch = state.canScratch();
        String remainingTime = state.remainingTime();

        // If the timer has completed, show a new scratch card
        if (canScratch && !_isCardVisible) {
          _resetScratchCard();
        }

        Color cardColor = _isScratched || !canScratch || !_isCardVisible
            ? Colors.grey
            : Colors.blue;

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onPanUpdate: (details) {
                    if (_isScratched || !canScratch || !_isCardVisible) return;

                    final RenderBox renderBox = _cardKey.currentContext!
                        .findRenderObject() as RenderBox;
                    final cardPosition = renderBox.localToGlobal(Offset.zero);
                    final cardSize = renderBox.size;

                    if (details.globalPosition.dx >= cardPosition.dx &&
                        details.globalPosition.dx <=
                            cardPosition.dx + cardSize.width &&
                        details.globalPosition.dy >= cardPosition.dy &&
                        details.globalPosition.dy <=
                            cardPosition.dy + cardSize.height) {
                      setState(() {
                        _scratchPoints.add(
                            renderBox.globalToLocal(details.globalPosition));
                        _scratchProgress = _scratchPoints.length / 100;
                        if (_scratchProgress >= 0.7) {
                          _isScratched = true;
                          _isCardVisible = false;

                          // Trigger reward logic
                          final reward = Random().nextInt(451) + 50;
                          context
                              .read<RewardBloc>()
                              .add(ScratchCardEvent(reward));
                          context.read<TransactionBloc>().add(
                                AddTransactionEvent(
                                    'Scratch Reward', reward, DateTime.now()),
                              );

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Congratulations!"),
                                content: Text("You won $reward coins!"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    }
                  },
                  child: _isCardVisible
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            key: _cardKey,
                            width: 300,
                            height: 300,
                            color: cardColor,
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    canScratch
                                        ? "Scratch to Win"
                                        : "No more scratches left",
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                CustomPaint(
                                  size: const Size(300, 300),
                                  painter: ScratchPainter(
                                      scratchPoints: _scratchPoints),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          width: 300,
                          height: 300,
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              remainingTime,
                              style: const TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ScratchPainter extends CustomPainter {
  final List<Offset?> scratchPoints;

  ScratchPainter({required this.scratchPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 30;

    for (var point in scratchPoints) {
      if (point != null) {
        canvas.drawCircle(point, 20, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}