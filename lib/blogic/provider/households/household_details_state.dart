
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';

class HouseholdDetailsState with ChangeNotifier {

  final HouseholdRepository _householdRepo;
  final ItemRepository _itemRepository;
  final String _householdId;

  Household? household;

  List<Item>? cartItems;
  List<String> selectedCartItemIds = [];

  List<Item>? fridgeItems;
  List<String> selectedFridgeItemIds= [];

  final List<StreamSubscription> _streamSubs = [];

  HouseholdDetailsState({ required ItemRepository itemRepository, required HouseholdRepository householdRepository, required String householdId}):
        _householdRepo = householdRepository,
        _householdId = householdId,
        _itemRepository = itemRepository
  {
    _streamSubs.add(_householdRepo.householdStream(householdId).listen((newHousehold) {
      household = newHousehold;
      notifyListeners();
    }));
    _streamSubs.add(_itemRepository.itemListStream(householdId, ItemCollection.cart).listen((newItems) {
      cartItems = newItems;
      filterSelectedCartItemIds();
      notifyListeners();
    }));
    _streamSubs.add(_itemRepository.itemListStream(householdId, ItemCollection.fridge).listen((newItems) {
      fridgeItems = newItems;
      filterSelectedFridgeItemIds();
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

  Future<void> moveSelectedCartItemsToFridge() async {
    if(cartItems == null) return;

    final List<Item> movedItems = [];
    for(final itemId in selectedCartItemIds){
      final item = getItemById(cartItems!, itemId);
      if(item == null) continue;
      movedItems.add(item);
    }

    await _itemRepository.moveItems(_householdId, ItemCollection.cart, ItemCollection.fridge, movedItems);
  }

  Future<void> moveSelectedFridgeItemsToCart() async {
    if(fridgeItems == null) return;

    final List<Item> movedItems = [];
    for(final itemId in selectedFridgeItemIds){
      final item = getItemById(fridgeItems!, itemId);
      if(item == null) continue;
      movedItems.add(item);
    }

    await _itemRepository.moveItems(_householdId, ItemCollection.fridge, ItemCollection.cart, movedItems);
  }

  Item? getItemById(List<Item> items, String id){
    Item? result;
    for (final item in items) {
      if(item.id == id){
        result = item;
      }
    }
    return result;
  }

  Future<void> removeSelectedCartItems() async{
    if(cartItems == null) return;

    final List<Item> removedItems = [];
    for(final itemId in selectedCartItemIds){
      final item = getItemById(cartItems!, itemId);
      if(item == null) continue;
      removedItems.add(item);
    }

    await _itemRepository.deleteItems(_householdId, ItemCollection.cart, removedItems);
  }

  Future<void> removeSelectedFridgeItems() async {
    if(fridgeItems == null) return;

    final List<Item> removedItems = [];
    for(final itemId in selectedFridgeItemIds){
      final item = getItemById(fridgeItems!, itemId);
      if(item == null) continue;
      removedItems.add(item);
    }

    await _itemRepository.deleteItems(_householdId, ItemCollection.fridge, removedItems);
  }

  void filterSelectedCartItemIds(){
    if (cartItems == null) return;
    selectedCartItemIds = selectedCartItemIds.where((id) => getItemById(cartItems!, id) != null).toList();
  }

  void filterSelectedFridgeItemIds(){
    if (fridgeItems == null) return;
    selectedFridgeItemIds = selectedFridgeItemIds.where((id) => getItemById(fridgeItems!, id) != null).toList();
  }


  @override
  void dispose(){
    for (var sub in _streamSubs) {
      sub.cancel();
    }
    super.dispose();
  }
}