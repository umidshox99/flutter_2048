import 'package:flutter/material.dart';

import '../models/tile.dart';

class AnimatedTile extends AnimatedWidget {
  //We use Listenable.merge in order to update the animated widget when both of the controllers have change
  AnimatedTile(
      {super.key,
        required this.moveController,
        required this.scaleController,
        required this.tile,
        required this.child,
        required this.size})
      : super(listenable: Listenable.merge([moveController, scaleController]));

  final Tile tile;
  final Widget child;
  final CurvedAnimation moveController;
  final CurvedAnimation scaleController;
  final double size;
  //Get the current top position based on current index of the tile
  late final double _top = tile.getTop(size);
  //Get the current left position based on current index of the tile
  late final double _left = tile.getLeft(size);
  //Get the next top position based on current next index of the tile
  late final double _nextTop = tile.getNextTop(size) ?? _top;
  //Get the next top position based on next index of the tile
  late final double _nextLeft = tile.getNextLeft(size) ?? _left;

  //top tween used to move the tile from top to bottom
  late final Animation<double> top = Tween<double>(
    begin: _top,
    end: _nextTop,
  ).animate(
    CurvedAnimation(
      parent: moveController,
      curve: Curves.easeInOut,
    ),
  ),
  //left tween used to move the tile from left to right
      left = Tween<double>(
        begin: _left,
        end: _nextLeft,
      ).animate(
        CurvedAnimation(
          parent: moveController,
          curve: Curves.easeInOut,
        ),
      ),
  //scale tween used to use give "pop" effect when a merge happens
      scale = TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 1.5)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 50.0,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.5, end: 1.0)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 50.0,
          ),
        ],
      ).animate(
        CurvedAnimation(
          parent: scaleController,
          curve: Curves.easeInOut,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: top.value,
        left: left.value,
        //Only use scale animation if the tile was merged
        child: tile.merged
            ? ScaleTransition(
          scale: scale,
          child: child,
        )
            : child);
  }
}