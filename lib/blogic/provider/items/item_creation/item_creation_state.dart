import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:uuid/uuid.dart';

import 'formz_inputs/inputs.dart';

enum ItemCreationResult {
  error,
  success,
  nothing
}

class ItemCreationState with ChangeNotifier {

  final ItemRepository _itemRepository;
  final String _houseHoldId;
  final ItemCollection _itemCollection;

  ItemCreationState({
    required ItemRepository itemRepository,
    required String householdId,
    required ItemCollection itemCollection
  }):
      _itemRepository = itemRepository,
      _houseHoldId = householdId,
      _itemCollection = itemCollection;

  Name name = const Name.pure();
  Amount amount = const Amount.pure();
  Unit unit = const Unit.pure();
  Description description = const Description.pure();
  FormzStatus formStatus = FormzStatus.pure;

  bool creationInProgress = false;

  ItemCreationResult creationResult = ItemCreationResult.nothing;

  void updateFormState(){
    formStatus = Formz.validate([
      name,
      amount,
      unit,
      description,
    ]);
    notifyListeners();
  }

  void changeName(String newName){
    name = Name.dirty(value: newName);
    updateFormState();
  }

  void changeAmount(String newAmount){
    amount = Amount.dirty(value: newAmount);
    updateFormState();
  }

  void changeUnit(String newUnit){
    unit = Unit.dirty(value: newUnit);
    updateFormState();
  }

  void changeDescription(String newDescription){
    description = Description.dirty(value: newDescription);
    updateFormState();
  }

  Future<void> createItem() async {
    if(creationInProgress){
      return;
    }
    creationInProgress = true;
    notifyListeners();
    final newItem = Item(
      id: const Uuid().v4(),
      amount: double.parse(amount.value),
      name: name.value,
      unit:  unit.value,
      description: description.value,
    );

    try{
      await _itemRepository.updateItem(_houseHoldId, _itemCollection, newItem);
    } on Exception {
      creationResult = ItemCreationResult.error;
      return;
    } finally{
      creationInProgress = false;
      notifyListeners();
    }
    creationResult = ItemCreationResult.success;
  }
}