
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';

class HouseholdDetailsState with ChangeNotifier {

  final HouseholdRepository _householdRepo;

  Household? household;
  late StreamSubscription _householdStreamSub;

  HouseholdDetailsState({ required HouseholdRepository householdRepository, required String householdId}):
        _householdRepo = householdRepository
  {
    _householdStreamSub = _householdRepo.householdStream(householdId).listen((newHousehold) {
      household = newHousehold;
      notifyListeners();
    });
  }

  @override
  void dispose(){
    _householdStreamSub.cancel();
    super.dispose();
  }
}