import 'package:flutter_bloc/flutter_bloc.dart';

class NavBarCubit extends Cubit<bool> {
  NavBarCubit() : super(true);

  void toggle() => emit(!state);

  void show() {
    if (!state) emit(true);
  }

  void hide() {
    if (state) emit(false);
  }
}
