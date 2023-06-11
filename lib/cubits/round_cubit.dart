import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class RoundCubit extends Cubit<bool> {
  RoundCubit() : super(true);

  void end() => emit(true);

  void begin() => emit(false);
}
