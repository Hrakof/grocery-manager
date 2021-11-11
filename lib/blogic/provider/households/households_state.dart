import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/models/invite_code/invite_code.dart';
import 'package:grocery_manager/models/user/user.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';
import 'package:grocery_manager/repositories/invite_code/invite_code_repository.dart';
import 'package:uuid/uuid.dart';

class HouseholdsState with ChangeNotifier {

  final User currentUser;
  final HouseholdRepository _householdRepo;
  final InviteCodeRepository _inviteCodeRepo;

  List<Household>? households;
  late StreamSubscription _streamSub;

  HouseholdsState({required InviteCodeRepository inviteCodeRepository, required HouseholdRepository householdRepository,required this.currentUser}):
        _householdRepo = householdRepository,
        _inviteCodeRepo = inviteCodeRepository
  {
    _streamSub = _householdRepo.getHouseholdsStreamForUser(currentUser).listen((newHouseholds) {
      households = newHouseholds;
      notifyListeners();
    });
  }

  Future<void> joinHousehold(String inviteCodeValue) async {
    final inviteCode = await _inviteCodeRepo.getInviteCodeByValue(inviteCodeValue);
    if(inviteCode == null) throw InvalidInviteCodeException(inviteCodeValue);
    final household = await _householdRepo.getHousehold(inviteCode.householdId);
    if(household == null) throw const HouseholdDoesNotExistException();
    if(household.memberUids.contains(currentUser.id)) throw const AlreadyMemberException();
    household.memberUids.add(currentUser.id);
    await _householdRepo.updateHousehold(household);
  }

  Future<void> createHousehold(String name) async {
    final household = Household(
      id: const Uuid().v4(),
      name: name,
      ownerUid: currentUser.id,
      memberUids: [ currentUser.id ],
    );
    final codeCreated = await _createInviteCode(household.id);
    if(codeCreated){
      await _householdRepo.updateHousehold(household);
    }
  }

  Future<bool> _createInviteCode(String householdId) async {
    int tries = 0;
    while(tries < 5){
      tries++;
      final newInviteCode = InviteCode(
        value: getRandomString(6),
        householdId: householdId,
        creationDate: DateTime.now(),
      );
      final success = await _inviteCodeRepo.createInviteCode(newInviteCode);
      if(success) return true;
    }
    return false;
  }

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random.secure();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  void dispose(){
    _streamSub.cancel();
    super.dispose();
  }
}

class InvalidInviteCodeException implements Exception {
  final String inviteCode;

  const InvalidInviteCodeException(this.inviteCode);
}

class HouseholdDoesNotExistException implements Exception {
  const HouseholdDoesNotExistException();
}

class AlreadyMemberException implements Exception {
  const AlreadyMemberException();
}
