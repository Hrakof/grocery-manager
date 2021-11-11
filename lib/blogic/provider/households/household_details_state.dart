
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/models/user/user.dart';
import 'package:grocery_manager/repositories/repositories.dart';

class HouseholdDetailsState with ChangeNotifier {

  final HouseholdRepository _householdRepo;
  final ItemRepository _itemRepository;
  final UserRepository _userRepository;
  final InviteCodeRepository _inviteCodeRepository;
  final String _householdId;

  Household? household;

  List<Item>? cartItems;
  List<String> selectedCartItemIds = [];

  List<Item>? fridgeItems;
  List<String> selectedFridgeItemIds = [];

  List<User> members = [];

  String inviteCode = "";
  bool householdDeleted = false;

  final List<StreamSubscription> _streamSubs = [];

  HouseholdDetailsState({ required InviteCodeRepository inviteCodeRepository, required UserRepository userRepository, required ItemRepository itemRepository, required HouseholdRepository householdRepository, required String householdId}):
        _householdRepo = householdRepository,
        _userRepository = userRepository,
        _inviteCodeRepository = inviteCodeRepository,
        _householdId = householdId,
        _itemRepository = itemRepository
  {
    _streamSubs.add(_householdRepo.householdStream(householdId).listen((newHousehold) async {
      if(newHousehold == null){
        householdDeleted = true;
        notifyListeners();
        return;
      }
      await _updateMemberNames(household, newHousehold);
      await _updateInviteCode(household, newHousehold);
      household = newHousehold;
      notifyListeners();
    }));
    _streamSubs.add(_itemRepository.itemListStream(householdId, ItemCollection.cart).listen((newItems) {
      cartItems = newItems;
      _filterSelectedCartItemIds();
      notifyListeners();
    }));
    _streamSubs.add(_itemRepository.itemListStream(householdId, ItemCollection.fridge).listen((newItems) {
      fridgeItems = newItems;
      _filterSelectedFridgeItemIds();
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
      final item = _getItemById(cartItems!, itemId);
      if(item == null) continue;
      movedItems.add(item);
    }

    await _itemRepository.moveItems(_householdId, ItemCollection.cart, ItemCollection.fridge, movedItems);
  }

  Future<void> moveSelectedFridgeItemsToCart() async {
    if(fridgeItems == null) return;

    final List<Item> movedItems = [];
    for(final itemId in selectedFridgeItemIds){
      final item = _getItemById(fridgeItems!, itemId);
      if(item == null) continue;
      movedItems.add(item);
    }

    await _itemRepository.moveItems(_householdId, ItemCollection.fridge, ItemCollection.cart, movedItems);
  }

  Item? _getItemById(List<Item> items, String id){
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
      final item = _getItemById(cartItems!, itemId);
      if(item == null) continue;
      removedItems.add(item);
    }

    await _itemRepository.deleteItems(_householdId, ItemCollection.cart, removedItems);
  }

  Future<void> removeSelectedFridgeItems() async {
    if(fridgeItems == null) return;

    final List<Item> removedItems = [];
    for(final itemId in selectedFridgeItemIds){
      final item = _getItemById(fridgeItems!, itemId);
      if(item == null) continue;
      removedItems.add(item);
    }

    await _itemRepository.deleteItems(_householdId, ItemCollection.fridge, removedItems);
  }

  void _filterSelectedCartItemIds(){
    if (cartItems == null) return;
    selectedCartItemIds = selectedCartItemIds.where((id) => _getItemById(cartItems!, id) != null).toList();
  }

  void _filterSelectedFridgeItemIds(){
    if (fridgeItems == null) return;
    selectedFridgeItemIds = selectedFridgeItemIds.where((id) => _getItemById(fridgeItems!, id) != null).toList();
  }

  Future<void> _updateMemberNames(Household? oldHousehold, Household newHousehold) async {
    if (oldHousehold != null && listEquals(oldHousehold.memberUids, newHousehold.memberUids)) return;

    final List<User> users = [];

    for (var uid in newHousehold.memberUids) {
      final user = await _userRepository.getUser(uid);
      if(user == null) continue;
      users.add(user);
    }
    members = users;
  }

  Future<void> _updateInviteCode(Household? oldHousehold, Household newHousehold) async {
    if (oldHousehold != null && oldHousehold.id == newHousehold.id) return;
    final newInviteCode = await _inviteCodeRepository.getInviteCodeOfHousehold(newHousehold.id);
    if(newInviteCode != null){
      inviteCode = newInviteCode.value;
    }
  }

  Future<void> leaveHousehold(String uid) async {
    if(household == null || household!.ownerUid == uid || !household!.memberUids.contains(uid)) return;
    final newMemberList = household!.memberUids.where((memberId) => memberId != uid).toList();
    final newHousehold = household!.copyWith(memberUids: newMemberList);
    await _householdRepo.updateHousehold(newHousehold);
  }

  Future<void> deleteHousehold(String uid) async {
    if(household == null || household!.ownerUid != uid) return;
    await _householdRepo.deleteHousehold(household!.id);
  }

  Future<void> kickMember(String uid) async {
    if(household == null || !household!.memberUids.contains(uid)) return;
    final newMemberList = household!.memberUids.where((memberId) => memberId != uid).toList();
    final newHousehold = household!.copyWith(memberUids: newMemberList);
    await _householdRepo.updateHousehold(newHousehold);
  }

  @override
  void dispose(){
    for (var sub in _streamSubs) {
      sub.cancel();
    }
    super.dispose();
  }
}