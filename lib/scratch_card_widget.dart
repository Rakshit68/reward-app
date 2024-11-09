import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
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
  // Scratch area
  List<Offset?> _scratchPoints = [];
  double _scratchProgress = 0.0;
  bool _isScratched = false;

  // Constants for the scratch detection
  final double scratchThreshold = 0.7;
  final int maxPoints = 100;

  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Setting states after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoUpdate();
    });
  }

  void _startAutoUpdate() {
    // Using a periodic timer
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RewardBloc, RewardState>(
      builder: (context, state) {
        //current scratch status
        bool canScratch = state.canScratch();
        String remainingTime = state.remainingTime();

        Color cardColor =
            _isScratched || !canScratch ? Colors.grey : Colors.blue;

        return GestureDetector(
          onPanUpdate: (details) {
            //checking scratching inside card area
            if (_isScratched) return;

            // Get the position and size of the card
            final RenderBox renderBox =
                _cardKey.currentContext!.findRenderObject() as RenderBox;
            final cardPosition = renderBox.localToGlobal(Offset.zero);
            final cardSize = renderBox.size;

            // Calculate if the touch is within the card's area
            if (details.globalPosition.dx >= cardPosition.dx &&
                details.globalPosition.dx <= cardPosition.dx + cardSize.width &&
                details.globalPosition.dy >= cardPosition.dy &&
                details.globalPosition.dy <=
                    cardPosition.dy + cardSize.height) {
              setState(() {
                _scratchPoints
                    .add(renderBox.globalToLocal(details.globalPosition));
                _scratchProgress = _scratchPoints.length / maxPoints;
                debugPrint('Scratch progress: $_scratchProgress');
                if (_scratchProgress >= scratchThreshold) {
                  _isScratched = true;
                }
              });
            }
          },
          onPanEnd: (_) {
            if (_scratchProgress >= scratchThreshold) {
              // Proceed to show reward when scratched more than 70%
              final reward = Random().nextInt(451) + 50;
              context.read<RewardBloc>().add(ScratchCardEvent(reward));
              context.read<TransactionBloc>().add(
                    AddTransactionEvent(
                        'Scratch Reward', reward, DateTime.now()),
                  );

              //scratched popup
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
              _scratchProgress = 0;
              _scratchPoints.clear();
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              key: _cardKey,
              width: 300,
              height: 300,
              color: cardColor,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  //card area
                  Container(
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        canScratch
                            ? "Scratch to Win"
                            : "No more scratches left",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  // The scratchable layer
                  CustomPaint(
                    size: const Size(200, 100),
                    painter: ScratchPainter(scratchPoints: _scratchPoints),
                  ),
                  //remaining time
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Text(
                      remainingTime,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
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

    // Draw all the scratched points
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
