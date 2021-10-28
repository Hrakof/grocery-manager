import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';

class ItemDetailsState with ChangeNotifier{

  Item? item;
  String? errorMessage;
  final ItemRepository _itemRepository;
  final String _householdId;
  final String _itemId;
  final ItemCollection _itemCollection;
  late StreamSubscription _itemSub;

  ItemDetailsState({required String householdId, required String itemId, required ItemCollection itemCollection, required ItemRepository itemRepository}):
    _itemRepository = itemRepository,
    _householdId = householdId,
    _itemId = itemId,
    _itemCollection = itemCollection
  {
    _itemSub = _itemRepository.itemStream(householdId, itemCollection, itemId).listen((item) {
      this.item = item;
      notifyListeners();
    });
  }

  Future<void> changeName(String newName) async{
    final oldItem = item;
    if(oldItem == null){
      return;
    }
    final newItem = oldItem.copyWith(name: newName);
    await _itemRepository.updateItem(_householdId, _itemCollection, newItem);
  }

  @override
  void dispose() {
    _itemSub.cancel();
    super.dispose();
  }
}