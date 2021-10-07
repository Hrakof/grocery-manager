
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:grocery_manager/models/user/user.dart';
import 'package:grocery_manager/repositories/user/user_repository.dart';

class LoginException implements Exception {
  String message;
  LoginException(this.message);
}

class SignUpException implements Exception {
  String message;
  SignUpException(this.message);
}

class AuthenticationRepository {

  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;

  final StreamController<String> _userStreamController = StreamController<String>();
  Stream<String> get userChangedStream => _userStreamController.stream;
  late StreamSubscription _fbStreamSubscription;
  final UserRepository _userRepository;

  AuthenticationRepository(this._userRepository){
    _fbStreamSubscription = _firebaseAuth.authStateChanges().listen((fbUser) async {
      print('--- auth state changes: ${fbUser?.uid}');
      if(fbUser == null){
        _userStreamController.add('');
        return;
      }
      _userStreamController.add(fbUser.uid);
    });
  }

  void dispose(){
    _fbStreamSubscription.cancel();
    _userStreamController.close();
  }

  Future<void> signUp({required String email, required String password, required String displayName}) async{
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _userRepository.createUser(User(
          id: credential.user!.uid,
          email: email,
          displayName: displayName
      ));
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw SignUpException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw SignUpException('The account already exists for that email.');
      }
      else{
        rethrow;
      }
    }
  }

  Future<void> login({required String email, required String password}) async{
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw LoginException('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw LoginException('Wrong password provided for that user.');
      }
      else {
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

}