

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/models/user/user.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';
import 'package:uuid/uuid.dart';

class HouseholdsState with ChangeNotifier {

  final User currentUser;
  final HouseholdRepository _householdRepo;

  List<Household>? households;
  late StreamSubscription _streamSub;

  HouseholdsState({ required HouseholdRepository householdRepository,required this.currentUser}):
        _householdRepo = householdRepository
  {
    _streamSub = _householdRepo.getHouseholdsStreamForUser(currentUser).listen((newHouseholds) {
      households = newHouseholds;
      notifyListeners();
    });
  }

  void createHousehold(String name){
    final household = Household(
        id: const Uuid().v4(),
        name: name,
        ownerUid: currentUser.id,
      memberUids: [ currentUser.id ],
    );
    _householdRepo.updateHousehold(household);
  }

  @override
  void dispose(){
    _streamSub.cancel();
    super.dispose();
  }
}