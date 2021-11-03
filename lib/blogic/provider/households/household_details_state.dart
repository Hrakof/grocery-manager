
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:grocery_manager/widgets/item_list.dart';

class HouseholdDetailsState with ChangeNotifier {

  final HouseholdRepository _householdRepo;
  final ItemRepository _itemRepository;
  final String _householdId;

  Household? household;

  List<Item>? cartItems;
  late GlobalKey<AnimatedListState> cartItemsListKey;
  final List<String> selectedCartItemIds = [];

  List<Item>? fridgeItems;
  late GlobalKey<AnimatedListState> fridgeItemsListKey;
  final List<String> selectedFridgeItemIds= [];

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
      cartItemsListKey = GlobalKey();
      notifyListeners();
    }));
    _streamSubs.add(_itemRepository.itemListStream(householdId, ItemCollection.fridge).listen((newItems) {
      fridgeItems = newItems;
      fridgeItemsListKey = GlobalKey();
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
      final idx = getIndexOfItemById(cartItems!, itemId);
      if(idx == null) continue;

      final item = cartItems!.removeAt(idx);
      movedItems.add(item);
      cartItemsListKey.currentState?.removeItem(
        idx,
        (_, animation){
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
            child: ItemTile(item, isChecked: true),
          );
        },
        duration: const Duration(milliseconds: 700)
      );
    }

    final List<String> savedCartItemIds = List.from(selectedCartItemIds);
    selectedCartItemIds.clear();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 750)); //wait for animation

    try{
      await _itemRepository.moveItems(_householdId, ItemCollection.cart, ItemCollection.fridge, movedItems);
    } on Exception {
      print('--- failed to move cart items');
      cartItems!.addAll(movedItems);
      selectedCartItemIds.addAll(savedCartItemIds);
      notifyListeners();
    }
  }

  Future<void> moveSelectedFridgeItemsToCart() async {
    if(fridgeItems == null) return;

    final List<Item> movedItems = [];
    for(final itemId in selectedFridgeItemIds){
      final idx = getIndexOfItemById(fridgeItems!, itemId);
      if(idx == null) continue;

      final item = fridgeItems!.removeAt(idx);
      movedItems.add(item);
      fridgeItemsListKey.currentState?.removeItem(
          idx,
          (_, animation){
            return SlideTransition(
              position: animation.drive(Tween(begin: const Offset(-1, 0), end: Offset.zero)),
              child: ItemTile(item, isChecked: true),
            );
          },
          duration: const Duration(milliseconds: 700)
      );
    }

    final List<String> savedFridgeItemIds = List.from(selectedFridgeItemIds);
    selectedFridgeItemIds.clear();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 750)); //wait for animation

    try{
      await _itemRepository.moveItems(_householdId, ItemCollection.fridge, ItemCollection.cart, movedItems);
    } on Exception {
      print('--- failed to move fridge items');
      fridgeItems!.addAll(movedItems);
      selectedFridgeItemIds.addAll(savedFridgeItemIds);
      notifyListeners();
    }
  }

  int? getIndexOfItemById(List<Item> items, String id){
    int? idx;
    items.asMap().forEach((index, item){
      if(item.id == id){
        idx = index;
      }
    });
    return idx;
  }

  Future<void> removeSelectedCartItems() async{
    if(cartItems == null) return;

    final List<Item> removedItems = [];
    for(final itemId in selectedCartItemIds){
      final idx = getIndexOfItemById(cartItems!, itemId);
      if(idx == null) continue;

      final item = cartItems!.removeAt(idx);
      removedItems.add(item);
      cartItemsListKey.currentState?.removeItem(
          idx,
          (_, animation){
            return SizeTransition(
              sizeFactor: animation,
              child: ItemTile(item, isChecked: true),
            );
          },
          duration: const Duration(milliseconds: 700)
      );
    }

    final List<String> savedCartItemIds = List.from(selectedCartItemIds);
    selectedCartItemIds.clear();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 750)); //wait for animation

    try{
      await _itemRepository.deleteItems(_householdId, ItemCollection.cart, removedItems);
    } on Exception {
      print('--- failed to remove cart items');
      cartItems!.addAll(removedItems);
      selectedCartItemIds.addAll(savedCartItemIds);
      notifyListeners();
    }
  }

  Future<void> removeSelectedFridgeItems() async {
    if(fridgeItems == null) return;

    final List<Item> removedItems = [];
    for(final itemId in selectedFridgeItemIds){
      final idx = getIndexOfItemById(fridgeItems!, itemId);
      if(idx == null) continue;

      final item = fridgeItems!.removeAt(idx);
      removedItems.add(item);
      fridgeItemsListKey.currentState?.removeItem(
          idx,
          (_, animation){
            return SizeTransition(
              sizeFactor: animation,
              child: ItemTile(item, isChecked: true),
            );
          },
          duration: const Duration(milliseconds: 700)
      );
    }

    final List<String> savedFridgeItemIds = List.from(selectedFridgeItemIds);
    selectedFridgeItemIds.clear();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 750)); //wait for animation

    try{
      await _itemRepository.deleteItems(_householdId, ItemCollection.fridge, removedItems);
    } on Exception {
      print('--- failed to remove fridge items');
      fridgeItems!.addAll(removedItems);
      selectedFridgeItemIds.addAll(savedFridgeItemIds);
      notifyListeners();
    }
  }

  @override
  void dispose(){
    for (var sub in _streamSubs) {
      sub.cancel();
    }
    super.dispose();
  }
}