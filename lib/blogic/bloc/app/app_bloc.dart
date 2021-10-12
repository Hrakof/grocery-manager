import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:grocery_manager/models/user/user.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';
import 'package:grocery_manager/repositories/user/user_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {

  StreamSubscription? _userSubscription;
  late final StreamSubscription _loginStreamSub;
  final AuthenticationRepository _authRepo;
  final UserRepository _userRepo;

  AppBloc({required AuthenticationRepository authenticationRepository, required UserRepository userRepository}) :
        _authRepo = authenticationRepository,
        _userRepo = userRepository,
        super(const UnAuthenticatedAppState())
  {
    _loginStreamSub = _authRepo.userChangedStream.listen((uid) {
      add(UserChangedEvent(uid: uid));
    });

    on<LogoutRequestedEvent>((event, emit) {
      _authRepo.logout();
    });
    on<UserChangedEvent>((event, emit) {
      _userSubscription?.cancel();
      if( event.uid == ""){
        emit(const UnAuthenticatedAppState());
      }
      else {
        _userSubscription = _userRepo.getUserStream(event.uid).listen((user) {
          add(UserDataArrivedEvent(user: user));
        });
      }
    });
    on<UserDataArrivedEvent>((event, emit) {
        emit(AuthenticatedAppState(currentUser: event.user));
    });
  }

  @override
  Future<void> close() {
    _loginStreamSub.cancel();
    _userSubscription?.cancel();
    _authRepo.dispose();
    return super.close();
  }

}
