import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_manager/blogic/provider/items/item_details_state.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/repositories.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'item_details_state_test.mocks.dart';


@GenerateMocks([ItemRepository])
void main() {
  group('HouseholdDetailsState tests.', () {

    final itemRepo = MockItemRepository();

    final cartItem = Item(
      id: 'cart_item_id',
      name: 'cart item',
      iconData: Icons.bug_report,
      amount: 2.0,
      unit: 'db',
      description: 'cart item description',
      expirationDate: DateTime.now(),
    );

    final fridgeItem = Item(
      id: 'fridge_item_id',
      name: 'fridge item',
      iconData: Icons.bug_report,
      amount: 1.0,
      unit: 'kg',
      description: 'fridge item description',
      expirationDate: DateTime.now(),
    );

    const householdId = 'household_id_123';

    late ItemDetailsState cartItemDetailsState;
    var cartListenerCallCount = 0;
    late ItemDetailsState fridgeItemDetailsState;
    var fridgeListenerCallCount = 0;

    setUp(() async {

      // ItemRepository
      reset(itemRepo);
      when(itemRepo.itemStream(householdId, ItemCollection.cart, cartItem.id))
          .thenAnswer((_) async* {
        yield cartItem;
      });
      when(itemRepo.itemStream(householdId, ItemCollection.fridge, fridgeItem.id))
          .thenAnswer((_) async* {
        yield fridgeItem;
      });

      cartItemDetailsState = ItemDetailsState(
          itemRepository: itemRepo,
          householdId: householdId,
          itemCollection: ItemCollection.cart,
          itemId: cartItem.id
      );
      cartListenerCallCount = 0;
      cartItemDetailsState.addListener(() => cartListenerCallCount++);

      fridgeItemDetailsState = ItemDetailsState(
          itemRepository: itemRepo,
          householdId: householdId,
          itemCollection: ItemCollection.fridge,
          itemId: fridgeItem.id
      );
      fridgeListenerCallCount = 0;
      fridgeItemDetailsState.addListener(() => fridgeListenerCallCount++);

      //wait for streams to send initial data
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('State setup. State gets set up correctly after item data arrives and listeners are notified.', () async {

      expect(cartItemDetailsState.item, cartItem);
      expect(cartListenerCallCount, 1);
      expect(fridgeItemDetailsState.item, fridgeItem);
      expect(fridgeListenerCallCount, 1);

    });

    test('Change name.', () async {

      await cartItemDetailsState.changeName('new cart item name');
      await fridgeItemDetailsState.changeName('new fridge item name');

      final newCartItem = cartItem.copyWith(name: 'new cart item name');
      final newFridgeItem = fridgeItem.copyWith(name: 'new fridge item name');

      verify(itemRepo.updateItem(householdId, ItemCollection.cart, newCartItem)).called(1);
      verify(itemRepo.updateItem(householdId, ItemCollection.fridge, newFridgeItem)).called(1);

    });

    test('Change amount.', () async {

      await cartItemDetailsState.changeAmount(11);
      await fridgeItemDetailsState.changeAmount(22);

      final newCartItem = cartItem.copyWith(amount: 11);
      final newFridgeItem = fridgeItem.copyWith(amount: 22);

      verify(itemRepo.updateItem(householdId, ItemCollection.cart, newCartItem)).called(1);
      verify(itemRepo.updateItem(householdId, ItemCollection.fridge, newFridgeItem)).called(1);

    });

    test('Change unit.', () async {

      await cartItemDetailsState.changeUnit('dkg');
      await fridgeItemDetailsState.changeUnit('m');

      final newCartItem = cartItem.copyWith(unit: 'dkg');
      final newFridgeItem = fridgeItem.copyWith(unit: 'm');

      verify(itemRepo.updateItem(householdId, ItemCollection.cart, newCartItem)).called(1);
      verify(itemRepo.updateItem(householdId, ItemCollection.fridge, newFridgeItem)).called(1);

    });

    test('Change description.', () async {

      await cartItemDetailsState.changeDescription('changed desc1');
      await fridgeItemDetailsState.changeDescription('changed desc2');

      final newCartItem = cartItem.copyWith(description: 'changed desc1');
      final newFridgeItem = fridgeItem.copyWith(description: 'changed desc2');

      verify(itemRepo.updateItem(householdId, ItemCollection.cart, newCartItem)).called(1);
      verify(itemRepo.updateItem(householdId, ItemCollection.fridge, newFridgeItem)).called(1);

    });

    test('Change icon.', () async {

      await cartItemDetailsState.changeIcon(Icons.email);
      await fridgeItemDetailsState.changeIcon(Icons.message);

      final newCartItem = cartItem.copyWith(iconData: Icons.email);
      final newFridgeItem = fridgeItem.copyWith(iconData: Icons.message);

      verify(itemRepo.updateItem(householdId, ItemCollection.cart, newCartItem)).called(1);
      verify(itemRepo.updateItem(householdId, ItemCollection.fridge, newFridgeItem)).called(1);

    });

    test('Change expiration date.', () async {
      final newCartItemDate = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 200));
      final newFridgeItemDate = DateTime.now();

      await cartItemDetailsState.changeExpirationDate(newCartItemDate);
      await fridgeItemDetailsState.changeExpirationDate(newFridgeItemDate);

      final newCartItem = cartItem.copyWith(expirationDate: newCartItemDate);
      final newFridgeItem = fridgeItem.copyWith(expirationDate: newFridgeItemDate);

      verify(itemRepo.updateItem(householdId, ItemCollection.cart, newCartItem)).called(1);
      verify(itemRepo.updateItem(householdId, ItemCollection.fridge, newFridgeItem)).called(1);

    });

    test('Item gets updated, when data changes.', () async {
      reset(itemRepo);
      when(itemRepo.itemStream(householdId, ItemCollection.cart, cartItem.id))
          .thenAnswer((_) async* {
        yield cartItem;
        await Future.delayed(const Duration(milliseconds: 50));
        yield cartItem.copyWith(name: 'something');
      });
      when(itemRepo.itemStream(householdId, ItemCollection.fridge, fridgeItem.id))
          .thenAnswer((_) async* {
        yield fridgeItem;
        await Future.delayed(const Duration(milliseconds: 50));
        yield fridgeItem.copyWith(name: 'something');
      });

      cartItemDetailsState = ItemDetailsState(
          itemRepository: itemRepo,
          householdId: householdId,
          itemCollection: ItemCollection.cart,
          itemId: cartItem.id
      );
      cartListenerCallCount = 0;
      cartItemDetailsState.addListener(() => cartListenerCallCount++);

      fridgeItemDetailsState = ItemDetailsState(
          itemRepository: itemRepo,
          householdId: householdId,
          itemCollection: ItemCollection.fridge,
          itemId: fridgeItem.id
      );
      fridgeListenerCallCount = 0;
      fridgeItemDetailsState.addListener(() => fridgeListenerCallCount++);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(cartItemDetailsState.item, cartItem);
      expect(cartListenerCallCount, 1);
      expect(fridgeItemDetailsState.item, fridgeItem);
      expect(fridgeListenerCallCount, 1);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cartItemDetailsState.item, cartItem.copyWith(name: 'something'));
      expect(cartListenerCallCount, 2);
      expect(fridgeItemDetailsState.item, fridgeItem.copyWith(name: 'something'));
      expect(fridgeListenerCallCount, 2);
    });

  });
}