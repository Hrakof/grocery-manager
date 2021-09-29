part of 'app_bloc.dart';

@immutable
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class LogoutRequestedEvent extends AppEvent {}

class UserChangedEvent extends AppEvent {

  const UserChangedEvent({required this.uid});

  final String uid;

  @override
  List<Object> get props => [uid];
}

class UserDataArrivedEvent extends AppEvent {

  const UserDataArrivedEvent({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}