import 'package:bloc/bloc.dart';
import 'package:book_app_f/data/repositories/user_repository.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/user_dto.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository userRepository;
  RegisterBloc({required this.userRepository}) : super(RegisterInitial()) {
    on<RegisterEvent>((event, emit) {});
  }
}
