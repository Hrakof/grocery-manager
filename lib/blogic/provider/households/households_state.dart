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

  Future<void> createHousehold(String name) async {
    final household = Household(
      id: const Uuid().v4(),
      name: name,
      ownerUid: currentUser.id,
      memberUids: [ currentUser.id ],
    );
    await _householdRepo.updateHousehold(household);
    await _createInviteCode(household.id);
  }

  Future<void> _createInviteCode(String householdId) async {
    bool done = false;
    while(!done){
      final newInviteCode = InviteCode(
        value: getRandomString(6),
        householdId: householdId,
        creationDate: DateTime.now(),
      );
      done = await _inviteCodeRepo.createInviteCode(newInviteCode);
    }
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