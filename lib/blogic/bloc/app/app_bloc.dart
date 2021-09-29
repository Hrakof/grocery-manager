import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:projekt/blogic/models/user.dart';
import 'package:projekt/repositories/authentication/authentication_repository.dart';
import 'package:projekt/repositories/user/user_repository.dart';

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

    on<AppEvent>((event, emit) {
      if ( event is LogoutRequestedEvent){
        _authRepo.logout();
      }
      else if( event is UserChangedEvent){
        if( event.uid == ""){
          _userSubscription?.cancel();
          emit(const UnAuthenticatedAppState());
          return;
        }
        if(state is UnAuthenticatedAppState){
          _userSubscription = _userRepo.userStream(event.uid).listen((user) {
            emit(AuthenticatedAppState(currentUser: user));
          });
        }
      }
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
