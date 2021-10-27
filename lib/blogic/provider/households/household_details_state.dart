
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
  List<Item>? cartItems;
  final List<String> selectedCartItemIds = [];
  List<Item>? fridgeItems;
  final List<String> selectedFridgeItemIds= [];

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

  void itemChecked(String itemId, ItemCollection itemCollection){
    switch (itemCollection) {
      case ItemCollection.cart:
        if(selectedCartItemIds.contains(itemId)){
          selectedCartItemIds.remove(itemId);
        }else{
          selectedCartItemIds.add(itemId);
        }
        break;
      case ItemCollection.fridge:
        if(selectedFridgeItemIds.contains(itemId)){
          selectedFridgeItemIds.remove(itemId);
        }else{
          selectedFridgeItemIds.add(itemId);
        }
        break;
    }
    notifyListeners();
  }

  @override
  void dispose(){
    for (var sub in _streamSubs) {
      sub.cancel();
    }
    super.dispose();
  }
}