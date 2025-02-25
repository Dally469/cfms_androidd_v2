import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginEvent({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userData;
  final bool isAdmin;

  const AuthAuthenticated({
    required this.userData,
    required this.isAdmin,
  });

  @override
  List<Object> get props => [userData, isAdmin];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object> get props => [error];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({
    required this.authRepository,
    required bool isLoggedIn,
    required String userData,
  }) : super(isLoggedIn && userData != 'no'
            ? AuthAuthenticated(
                userData: userData, isAdmin: _isUserAdmin(userData))
            : AuthUnauthenticated()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.login(event.username, event.password);
      if (result.success) {
        // emit(AuthAuthenticated(
        //   userData: result.userData,
        //   isAdmin: _isUserAdmin(result.userData),
        // ));
      } else {
        emit(AuthFailure(result.errorMessage ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final isAuthenticated = await authRepository.isAuthenticated();
    if (isAuthenticated.isLoggedIn) {
      emit(AuthAuthenticated(
        userData: isAuthenticated.userData ?? 'no',
        isAdmin: _isUserAdmin(isAuthenticated.userData ?? 'no'),
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  static bool _isUserAdmin(String userData) {
    // Implement logic to check if user is admin based on userData
    // This is a placeholder - replace with actual implementation
    return userData.contains('admin');
  }
}
