
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';

class HouseholdDetailsState with ChangeNotifier {

  final HouseholdRepository _householdRepo;
  final ItemRepository _itemRepository;

  Household? household;
  //TODO handle item selection
  List<Item>? cartItems;
  List<Item>? fridgeItems;

  final List<StreamSubscription> _streamSubs = [];

  HouseholdDetailsState({ required ItemRepository itemRepository, required HouseholdRepository householdRepository, required String householdId}):
        _householdRepo = householdRepository,
        _itemRepository = itemRepository
  {
    _streamSubs.add(_householdRepo.householdStream(householdId).listen((newHousehold) {
      household = newHousehold;
      notifyListeners();
    }));
    _streamSubs.add(_itemRepository.itemListStream(householdId, ItemCollection.cart).listen((newItems) {
      cartItems = newItems;
      notifyListeners();
    }));
    _streamSubs.add(_itemRepository.itemListStream(householdId, ItemCollection.fridge).listen((newItems) {
      fridgeItems = newItems;
      notifyListeners();
    }));
  }



  @override
  void dispose(){
    for (var sub in _streamSubs) {
      sub.cancel();
    }
    super.dispose();
  }
}