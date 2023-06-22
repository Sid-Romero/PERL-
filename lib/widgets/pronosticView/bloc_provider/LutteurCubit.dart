import 'package:flutter_bloc/flutter_bloc.dart';

class LutteurCubit extends Cubit<String> {
  LutteurCubit(String defaultValue) : super(defaultValue);

  void updateLutteur(String newValue) {
    emit(newValue);
  }
}
