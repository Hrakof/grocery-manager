part of 'app_bloc.dart';

@immutable
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class UnAuthenticatedAppState extends AppState {
  const UnAuthenticatedAppState();
}

class AuthenticatedAppState extends AppState {
  final User currentUser;

  const AuthenticatedAppState({required this.currentUser});

  @override
  List<Object> get props => [currentUser];
}
