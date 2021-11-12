import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/provider/items/item_creation/formz_inputs/inputs.dart' as inputs;
import 'package:grocery_manager/blogic/provider/items/item_creation/item_creation_state.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/repositories.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'item_creation_state_test.mocks.dart';



@GenerateMocks([ItemRepository])
void main() {
  group('HouseholdDetailsState tests.', () {

    final itemRepo = MockItemRepository();

    const householdId = 'household_id_123';

    late ItemCreationState itemCreationState;

    setUp(() async {

      reset(itemRepo);

      itemCreationState = ItemCreationState(
          itemRepository: itemRepo,
          householdId: householdId,
          itemCollection: ItemCollection.cart
      );

    });

    test('State setup.', () async {

      expect(itemCreationState.description, const inputs.Description.pure());
      expect(itemCreationState.amount, const inputs.Amount.pure());
      expect(itemCreationState.name, const inputs.Name.pure());
      expect(itemCreationState.unit, const inputs.Unit.pure());
      expect(itemCreationState.formStatus, FormzStatus.pure );
      expect(itemCreationState.creationInProgress, false);
      expect(itemCreationState.creationResult, ItemCreationResult.nothing);

    });

    test('Change fields.', () async {
      itemCreationState.changeDescription('new desc');
      expect(itemCreationState.formStatus, FormzStatus.invalid);
      itemCreationState.changeUnit('kg');
      expect(itemCreationState.formStatus, FormzStatus.invalid);
      itemCreationState.changeAmount('3');
      expect(itemCreationState.formStatus, FormzStatus.invalid);
      itemCreationState.changeName('new name');

      expect(itemCreationState.description, const inputs.Description.dirty(value: 'new desc'));
      expect(itemCreationState.amount, const inputs.Amount.dirty(value: '3'));
      expect(itemCreationState.name, const inputs.Name.dirty(value: 'new name'));
      expect(itemCreationState.unit, const inputs.Unit.dirty(value: 'kg'));
      expect(itemCreationState.formStatus, FormzStatus.valid);

    });

    test('Try to create item without name.', () async {
      itemCreationState.changeAmount('3');
      itemCreationState.createItem();

      verifyNever(itemRepo.updateItem(any, any, any));
    });

    test('Create item.', () async {
      itemCreationState.changeName('new name');
      expect(itemCreationState.formStatus, FormzStatus.valid);
      itemCreationState.changeAmount('3');

      itemCreationState.createItem();
      final arguments = verify(itemRepo.updateItem(householdId, any, captureAny)).captured;
      expect(arguments.length, 1);

      final createdItem = arguments[0] as Item;
      expect(createdItem.name, 'new name');
      expect(createdItem.amount, 3.0);
      expect(createdItem.iconData, Icons.description);
      expect(createdItem.expirationDate, null);
      expect(createdItem.unit, null);
      expect(createdItem.description, null);
    });

  });
}