part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String address;
  final String phone;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.phone,
  });

  @override
  List<Object> get props => [name, email, password, address, phone];
}

class GetCurrentUserRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String address;
  final String phone;

  const UpdateProfileRequested({
    required this.address,
    required this.phone,
  });

  @override
  List<Object> get props => [address, phone];
}
