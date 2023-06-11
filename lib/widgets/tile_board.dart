import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled8/widgets/animated_tile.dart';
import 'package:untitled8/widgets/button_widget.dart';
import 'package:untitled8/const/colors.dart';
import 'package:untitled8/cubits/board_cubit.dart';

class TileBoardWidget extends StatelessWidget {
  const TileBoardWidget(
      {super.key, required this.moveAnimation, required this.scaleAnimation});

  final CurvedAnimation moveAnimation;
  final CurvedAnimation scaleAnimation;

  @override
  Widget build(
    BuildContext context,
  ) {
    final board = context.read<BoardCubit>();
    if (board.state.over) {
      return Positioned.fill(
          child: Container(
        color: overlayColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              board.state.won ? 'You win!' : 'Game over!',
              style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 64.0),
            ),
            ButtonWidget(
              text: board.state.won ? 'New Game' : 'Try again',
              onPressed: () {
                context.read<BoardCubit>().newGame();
              },
            )
          ],
        ),
      ));
    }

    //Decides the maximum size the Board can be based on the shortest size of the screen.
    final size = max(
        290.0,
        min((MediaQuery.of(context).size.shortestSide * 0.90).floorToDouble(),
            460.0));

    //Decide the size of the tile based on the size of the board minus the space between each tile.
    final sizePerTile = (size / 4).floorToDouble();
    final tileSize = sizePerTile - 12.0 - (12.0 / 4);
    final boardSize = sizePerTile * 4;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          ...List.generate(
            board.state.tiles.length,
            (i) {
              var tile = board.state.tiles[i];
              return AnimatedTile(
                key: ValueKey(tile.id),
                scaleController: scaleAnimation,
                moveController: moveAnimation,
                tile: tile,
                size: tileSize,
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                      color: tileColors[tile.value],
                      borderRadius: BorderRadius.circular(6.0)),
                  child: Center(
                    child: Text(
                      '${tile.value}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          color: tile.value < 8 ? textColor : textColorWhite),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
