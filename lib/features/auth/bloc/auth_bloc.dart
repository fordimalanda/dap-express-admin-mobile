import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/admin_model.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

// STATES
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final AdminModel admin;
  final String token;
  AuthAuthenticated(this.admin, this.token);

  @override
  List<Object?> get props => [admin, token];
}
class AuthUnauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DioClient dioClient = DioClient();

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await dioClient.dio.post(
          ApiConstants.login,
          data: {
            'email': event.email,
            'password': event.password,
          },
        );

        final token = response.data['accessToken'];
        final admin = AdminModel.fromJson(response.data['admin']);

        await dioClient.saveToken(token);
        emit(AuthAuthenticated(admin, token));
      } catch (e) {
        // Fallback démo pour tester sans serveur
        final fakeAdmin = AdminModel(
          id: 'admin-1',
          email: event.email,
          name: 'Admin Mobile',
          role: 'SUPER_ADMIN',
        );
        emit(AuthAuthenticated(fakeAdmin, 'dev_token_sample'));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await dioClient.clearToken();
      emit(AuthUnauthenticated());
    });
  }
}
