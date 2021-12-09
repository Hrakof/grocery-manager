import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/models/invite_code/invite_code.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/models/user/user.dart';
import 'package:grocery_manager/repositories/repositories.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'household_details_test.mocks.dart';

@GenerateMocks([InviteCodeRepository, HouseholdRepository, ItemRepository, UserRepository])
void main() {
  group('HouseholdDetailsState tests.', () {

    final householdRepo = MockHouseholdRepository();
    final itemRepo = MockItemRepository();
    final userRepo = MockUserRepository();
    final inviteCodeRepo = MockInviteCodeRepository();

    const owner = User(displayName: 'owner name', id: 'owner_id', email: 'owner@email.com');
    const member = User(displayName: 'member name', id: 'member_id', email: 'member@email.com');
    const household = Household(
      id: 'household_id_123',
      name: 'test household name',
      ownerUid: 'owner_id',
      memberUids: [ 'owner_id', 'member_id' ]
    );
    final inviteCode = InviteCode(value: 'invite_code', householdId: household.id, creationDate: DateTime.now());
    const cartItems = [
      Item(id: 'cart_item_1', name: 'cart item 1', iconData: Icons.bug_report),
      Item(id: 'cart_item_2', name: 'cart item 2', iconData: Icons.bug_report),
      Item(id: 'cart_item_3', name: 'cart item 3', iconData: Icons.bug_report),
    ];
    const fridgeItems = [
      Item(id: 'fridge_item_1', name: 'fridge item 1', iconData: Icons.bug_report),
      Item(id: 'fridge_item_2', name: 'fridge item 2', iconData: Icons.bug_report),
      Item(id: 'fridge_item_3', name: 'fridge item 3', iconData: Icons.bug_report),
    ];

    late HouseholdDetailsState householdDetailsState;

    setUp(() async {
      // HouseholdRepository
      reset(householdRepo);
      when(householdRepo.householdStream(household.id))
          .thenAnswer((_) async* {
        yield household;
      });

      // ItemRepository
      reset(itemRepo);
      when(itemRepo.itemListStream(household.id, ItemCollection.cart))
          .thenAnswer((_) async* {
        yield cartItems;
      });
      when(itemRepo.itemListStream(household.id, ItemCollection.fridge))
          .thenAnswer((_) async* {
        yield fridgeItems;
      });

      // UserRepository
      reset(userRepo);
      when(userRepo.getUser(owner.id))
          .thenAnswer((_) async {
        return owner;
      });
      when(userRepo.getUser(member.id))
          .thenAnswer((_) async {
        return member;
      });

      // InviteCodeRepository
      reset(inviteCodeRepo);
      when(inviteCodeRepo.getInviteCodeOfHousehold(household.id))
          .thenAnswer((_) async {
        return inviteCode;
      });

      householdDetailsState = HouseholdDetailsState(
          inviteCodeRepository: inviteCodeRepo,
          userRepository: userRepo,
          itemRepository: itemRepo,
          householdRepository: householdRepo,
          householdId: household.id
      );
      //wait for streams to send initial data
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      householdDetailsState.dispose();
    });

    test('State setup. State gets set up correctly after household data and item lists arrive and listeners are notified.', () async {
      //state is created here, so the listener can count
      householdDetailsState = HouseholdDetailsState(
          inviteCodeRepository: inviteCodeRepo,
          userRepository: userRepo,
          itemRepository: itemRepo,
          householdRepository: householdRepo,
          householdId: household.id
      );

      var listenerCallCount = 0;
      householdDetailsState.addListener(() => listenerCallCount++);

      //wait for streams to send initial data
      await Future.delayed(const Duration(milliseconds: 100));

      expect(householdDetailsState.inviteCode, inviteCode.value);
      expect(householdDetailsState.cartItems, cartItems);
      expect(householdDetailsState.fridgeItems, fridgeItems );
      expect(householdDetailsState.household, household);
      expect(householdDetailsState.selectedCartItemIds, []);
      expect(householdDetailsState.selectedFridgeItemIds, []);
      expect(householdDetailsState.members, [owner, member]);
      expect(listenerCallCount, 3);

    });

    test('Select some items then move them from cart to fridge.', () async {

      householdDetailsState.itemChecked(cartItems[0].id, ItemCollection.cart);
      householdDetailsState.itemChecked(cartItems[2].id, ItemCollection.cart);

      expect(householdDetailsState.selectedCartItemIds, [cartItems[0].id, cartItems[2].id]);

      await householdDetailsState.moveSelectedCartItemsToFridge();

      verify(itemRepo.moveItems(household.id, ItemCollection.cart, ItemCollection.fridge, [cartItems[0], cartItems[2]])).called(1);

    });

    test('Select some items then move them from fridge to cart.', () async {

      householdDetailsState.itemChecked(fridgeItems[1].id, ItemCollection.fridge);
      householdDetailsState.itemChecked(fridgeItems[0].id, ItemCollection.fridge);

      expect(householdDetailsState.selectedFridgeItemIds, [fridgeItems[1].id, fridgeItems[0].id]);

      await householdDetailsState.moveSelectedFridgeItemsToCart();

      verify(itemRepo.moveItems(household.id, ItemCollection.fridge, ItemCollection.cart, [fridgeItems[1], fridgeItems[0]])).called(1);

    });

    test('Select some items then remove them.', () async {

      householdDetailsState.itemChecked(fridgeItems[0].id, ItemCollection.fridge);
      householdDetailsState.itemChecked(fridgeItems[2].id, ItemCollection.fridge);
      householdDetailsState.itemChecked(cartItems[1].id, ItemCollection.cart);

      expect(householdDetailsState.selectedFridgeItemIds, [fridgeItems[0].id, fridgeItems[2].id]);
      expect(householdDetailsState.selectedCartItemIds, [cartItems[1].id]);

      await householdDetailsState.removeSelectedCartItems();
      await householdDetailsState.removeSelectedFridgeItems();

      verify(itemRepo.deleteItems(household.id, ItemCollection.fridge, [fridgeItems[0], fridgeItems[2]])).called(1);
      verify(itemRepo.deleteItems(household.id, ItemCollection.cart, [cartItems[1]])).called(1);
    });

    test('Select some items then clear some selections.', () async {

      householdDetailsState.itemChecked(fridgeItems[0].id, ItemCollection.fridge);
      householdDetailsState.itemChecked(fridgeItems[2].id, ItemCollection.fridge);
      householdDetailsState.itemChecked(cartItems[1].id, ItemCollection.cart);

      expect(householdDetailsState.selectedFridgeItemIds, [fridgeItems[0].id, fridgeItems[2].id]);
      expect(householdDetailsState.selectedCartItemIds, [cartItems[1].id]);

      householdDetailsState.itemChecked(fridgeItems[2].id, ItemCollection.fridge);
      householdDetailsState.itemChecked(cartItems[1].id, ItemCollection.cart);

      expect(householdDetailsState.selectedFridgeItemIds, [fridgeItems[0].id]);
      expect(householdDetailsState.selectedCartItemIds, []);

    });

    test('Owner cant leave the household.', () async {

      await householdDetailsState.leaveHousehold(owner.id);

      verifyNever(householdRepo.updateHousehold(any));
    });

    test('Member leaves the household.', () async {

      await householdDetailsState.leaveHousehold(member.id);

      verify(householdRepo.updateHousehold(Household(
          id: household.id,
          name: household.name,
          ownerUid: household.ownerUid,
          memberUids: [owner.id],
      ))).called(1);
    });

    test('Owner can delete the household.', () async {

      await householdDetailsState.deleteHousehold(owner.id);

      verify(householdRepo.deleteHousehold(household.id)).called(1);
    });

    test('Members can not delete the household.', () async {

      await householdDetailsState.deleteHousehold(member.id);

      verifyNever(householdRepo.deleteHousehold(any));
    });

    test('Household gets deleted.', () async {

      reset(householdRepo);
      when(householdRepo.householdStream(household.id))
          .thenAnswer((_) async* {
        yield household;
        await Future.delayed(const Duration(milliseconds: 100));
        yield null;
      });

      householdDetailsState = HouseholdDetailsState(
          inviteCodeRepository: inviteCodeRepo,
          userRepository: userRepo,
          itemRepository: itemRepo,
          householdRepository: householdRepo,
          householdId: household.id
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(householdDetailsState.householdDeleted, false);
      await Future.delayed(const Duration(milliseconds: 150));
      expect(householdDetailsState.householdDeleted, true);

    });

    test('Selected items lists gets updated, when new item list arrives.', () async {

      reset(itemRepo);
      when(itemRepo.itemListStream(household.id, ItemCollection.cart))
          .thenAnswer((_) async* {
        yield cartItems;
        await Future.delayed(const Duration(milliseconds: 100));
        yield [cartItems[1], cartItems[2]];
      });
      when(itemRepo.itemListStream(household.id, ItemCollection.fridge))
          .thenAnswer((_) async* {
        yield fridgeItems;
        await Future.delayed(const Duration(milliseconds: 100));
        yield [fridgeItems[0], fridgeItems[2]];
      });

      householdDetailsState = HouseholdDetailsState(
          inviteCodeRepository: inviteCodeRepo,
          userRepository: userRepo,
          itemRepository: itemRepo,
          householdRepository: householdRepo,
          householdId: household.id
      );

      householdDetailsState.itemChecked(cartItems[0].id, ItemCollection.cart);
      householdDetailsState.itemChecked(cartItems[1].id, ItemCollection.cart);
      householdDetailsState.itemChecked(fridgeItems[0].id, ItemCollection.fridge);
      householdDetailsState.itemChecked(fridgeItems[1].id, ItemCollection.fridge);


      expect(householdDetailsState.selectedCartItemIds, [cartItems[0].id, cartItems[1].id]);
      expect(householdDetailsState.selectedFridgeItemIds, [fridgeItems[0].id, fridgeItems[1].id]);

      await Future.delayed(const Duration(milliseconds: 200));

      expect(householdDetailsState.selectedCartItemIds, [cartItems[1].id]);
      expect(householdDetailsState.selectedFridgeItemIds, [fridgeItems[0].id]);

    });


  });
}