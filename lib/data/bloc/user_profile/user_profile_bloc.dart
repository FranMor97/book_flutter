// lib/data/bloc/user_profile/user_profile_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/user_dto.dart';
import '../../repositories/user_repository.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final IUserRepository userRepository;

  UserProfileBloc({required this.userRepository})
      : super(UserProfileInitial()) {
    on<UserProfileLoad>(_onUserProfileLoad);
    on<UserProfileUpdate>(_onUserProfileUpdate);
  }

  Future<void> _onUserProfileLoad(
    UserProfileLoad event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    try {
      final user = await userRepository.getUserWithStoredToken();
      if (user != null) {
        emit(UserProfileLoaded(user: user));
      } else {
        emit(const UserProfileError(
            message: 'No se pudo cargar el perfil del usuario'));
      }
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }

  Future<void> _onUserProfileUpdate(
    UserProfileUpdate event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileUpdating());

    try {
      final updatedUser = await userRepository.updateProfile(event.userDto);
      emit(UserProfileUpdateSuccess(user: updatedUser));

      // Emitir el estado cargado con los datos actualizados
      emit(UserProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }
}
