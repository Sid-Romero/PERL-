import 'package:flutter_bloc/flutter_bloc.dart';

class DurationCubit extends Cubit<String> {
  DurationCubit() : super('Non voté');

  void updateDuration(String newDuration) {
    emit(newDuration);
  }
}
