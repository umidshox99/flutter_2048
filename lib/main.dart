import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled8/widgets/button_widget.dart';
import 'package:untitled8/widgets/empty_board.dart';
import 'package:untitled8/widgets/tile_board.dart';
import 'package:untitled8/cubits/board_adapter.dart';
import 'package:untitled8/cubits/board_cubit.dart';
import 'package:untitled8/cubits/next_direction_cubit.dart';
import 'package:untitled8/cubits/round_cubit.dart';
import 'package:untitled8/models/board.dart';

import 'widgets/score_board.dart';
import 'const/colors.dart';

void main() async {
  //Allow only portrait mode on Android & iOS
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  //Make sure Hive is initialized first and only after register the adapter.
  await Hive.initFlutter();
  Hive.registerAdapter(BoardAdapter());
  runApp(MaterialApp(
    title: '2048',
    home: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BoardCubit(),
        ),
        BlocProvider(
          create: (context) => NextDirectionCubit(),
        ),
        BlocProvider(
          create: (context) => RoundCubit(),
        ),
      ],
      child: Game(),
    ),
  ));
}

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //The contoller used to move the the tiles
  late final AnimationController _moveController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  )..addStatusListener((status) {
      //When the movement finishes merge the tiles and start the scale animation which gives the pop effect.
      if (status == AnimationStatus.completed) {
        context.read<BoardCubit>().merge();
        _scaleController.forward(from: 0.0);
      }
    });

//The curve animation for the move animation controller.
  late final CurvedAnimation _moveAnimation = CurvedAnimation(
    parent: _moveController,
    curve: Curves.easeInOut,
  );

//The contoller used to show a popup effect when the tiles get merged
  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  )..addStatusListener((status) {
      //When the scale animation finishes end the round and if there is a queued movement start the move controller again for the next direction.
      if (status == AnimationStatus.completed) {
        if (context.read<BoardCubit>().endRound(
              context.read<RoundCubit>(),
              context.read<NextDirectionCubit>(),
            )) {
          _moveController.forward(from: 0.0);
        }
      }
    });

//The curve animation for the scale animation controller.
  late final CurvedAnimation _scaleAnimation = CurvedAnimation(
    parent: _scaleController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    //Add an Observer for the Lifecycles of the App
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardCubit, Board>(
      builder: (context, boardState) {
        return BlocBuilder<NextDirectionCubit, SwipeDirection?>(
          builder: (context, swipeDirectionState) {
            return BlocBuilder<RoundCubit, bool>(
              builder: (context, roundState) {
                return RawKeyboardListener(
                  autofocus: true,
                  focusNode: FocusNode(),
                  onKey: (RawKeyEvent event) {
                    //Move the tile with the arrows on the keyboard on Desktop
                  },
                  child: SwipeDetector(
                    onSwipe: (direction, offset) {
                      if (context.read<BoardCubit>().move(direction)) {
                        _moveController.forward(from: 0.0);
                      }
                    },
                    child: Scaffold(
                      backgroundColor: backgroundColor,
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '2048',
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 52.0),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const ScoreBoard(),
                                    const SizedBox(
                                      height: 32.0,
                                    ),
                                    Row(
                                      children: [
                                        ButtonWidget(
                                          icon: Icons.undo,
                                          onPressed: () {
                                            context.read<BoardCubit>().undo();
                                            //Undo the round.
                                          },
                                        ),
                                        const SizedBox(
                                          width: 16.0,
                                        ),
                                        ButtonWidget(
                                          icon: Icons.refresh,
                                          onPressed: () {
                                            context
                                                .read<BoardCubit>()
                                                .newGame();
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 32.0,
                          ),
                          Stack(
                            children: [
                              const EmptyBoardWidget(),
                              TileBoardWidget(
                                  moveAnimation: _moveAnimation,
                                  scaleAnimation: _scaleAnimation)
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Save current state when the app becomes inactive
    if (state == AppLifecycleState.inactive) {
      context.read<BoardCubit>().save();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    //Dispose the animations.
    _moveAnimation.dispose();
    _scaleAnimation.dispose();
    _moveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
