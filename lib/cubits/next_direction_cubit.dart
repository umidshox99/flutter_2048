import 'package:bloc/bloc.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';


class NextDirectionCubit extends Cubit<SwipeDirection?> {
  NextDirectionCubit() : super(null);

  void queue(direction) =>emit(direction);

  void clear() =>emit(null);
}
