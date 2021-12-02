import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_manager/blogic/provider/households/households_state.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/models/invite_code/invite_code.dart';
import 'package:grocery_manager/models/user/user.dart';
import 'package:grocery_manager/repositories/repositories.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'households_state_test.mocks.dart';

@GenerateMocks([InviteCodeRepository, HouseholdRepository])
void main() {
  group('HouseholdsState tests.', () {
    const currentUser = User(
        email: 'testuser@test.com',
        displayName: 'test user',
        id: 'uid123'
    );

    final inviteCodeRepo = MockInviteCodeRepository();
    final householdRepo = MockHouseholdRepository();

    late HouseholdsState householdsState;

    setUp((){
      reset(householdRepo);
      reset(inviteCodeRepo);
      when(householdRepo.getHouseholdsStreamForUser(currentUser))
          .thenAnswer((_) async* {
        yield [];
      });
      householdsState = HouseholdsState(
          inviteCodeRepository: inviteCodeRepo,
          householdRepository: householdRepo,
          currentUser: currentUser
      );
    });

    tearDown((){
      householdsState.dispose();
    });

    test('Invite code not found during joining household. InvalidInviteCodeException should be thrown.', () {

      when(inviteCodeRepo.getInviteCodeByValue('inviteCode123'))
      .thenAnswer((_) async {
        return null;
      });

      expect(householdsState.joinHousehold('inviteCode123'), throwsA(const TypeMatcher<InvalidInviteCodeException>()));
    });

    test('Successfully joining household. HouseholdRepository.updateHousehold should be called with the updated member list.', () async {

      when(inviteCodeRepo.getInviteCodeByValue('inviteCode123'))
          .thenAnswer((_) async {
        return InviteCode(
            creationDate: DateTime.now(),
            value: 'inviteCode123',
            householdId: 'householdId123'
        );
      });

      when(householdRepo.getHousehold('householdId123'))
          .thenAnswer((_) async {
        // ignore: prefer_const_constructors
        return Household(
            id: 'householdId123',
            name: 'test household',
            ownerUid: 'ownerId123',
            // ignore: prefer_const_literals_to_create_immutables
            memberUids: ['ownerId123'] //has to be modifiable list
        );
      });

      await householdsState.joinHousehold('inviteCode123');

      verify(householdRepo.updateHousehold(const Household(
          id: 'householdId123',
          name: 'test household',
          ownerUid: 'ownerId123',
          memberUids: ['ownerId123', 'uid123']
      ))).called(1);

    });

    test('Create a new household and invite code with right parameters.', () async {

      when(inviteCodeRepo.createInviteCode(any))
          .thenAnswer((_) async {
        return true;
      });

      await householdsState.createHousehold('New household name');

      final updateHouseholdPassedArguments = verify(householdRepo.updateHousehold(captureAny)).captured;
      expect(updateHouseholdPassedArguments.length, 1); //should be called only once

      //Created household with right parameters
      final createdHousehold = updateHouseholdPassedArguments[0] as Household;
      expect(createdHousehold.name, 'New household name');
      expect(createdHousehold.ownerUid, currentUser.id);
      expect(createdHousehold.memberUids, [currentUser.id]);

      final createInviteCodeCapturedArguments = verify(inviteCodeRepo.createInviteCode(captureAny)).captured;
      expect(createInviteCodeCapturedArguments.length, 1); //should be called only once

      //Created invite code with right parameters
      final createdInviteCode = createInviteCodeCapturedArguments[0] as InviteCode;
      expect(createdInviteCode.householdId, createdHousehold.id);
    });

    test('Create a new household. InviteCode generation fails for the first two times, should try until successful.', () async {

      int tries = 0;
      when(inviteCodeRepo.createInviteCode(any))
          .thenAnswer((_) async {
            tries++;
            if (tries < 3){
              return false;
            }
            return true;
      });

      await householdsState.createHousehold('New household name');

      verify(inviteCodeRepo.createInviteCode(any)).called(3); // First 2 tries failed
      verify(householdRepo.updateHousehold(any)).called(1);

    });

    test('Create a new household. InviteCode generation fails 5 times so household should not be created.', () async {

      when(inviteCodeRepo.createInviteCode(any))
          .thenAnswer((_) async {
        return false;
      });

      await householdsState.createHousehold('New household name');

      verify(inviteCodeRepo.createInviteCode(any)).called(5);
      verifyNever(householdRepo.updateHousehold(any));
    });

    test('New household list arrives. List should be updated and listeners should be notified.', () async {

      when(inviteCodeRepo.createInviteCode(any))
          .thenAnswer((_) async {
        return false;
      });

      const householdList = [
        Household(id: 'id1', name: 'name1', ownerUid: 'uid1', memberUids: ['uid1']),
        Household(id: 'id2', name: 'name2', ownerUid: 'uid2', memberUids: ['uid2', 'uid1']),
      ];
      when(householdRepo.getHouseholdsStreamForUser(currentUser))
          .thenAnswer((_) async* {
        await Future.delayed(const Duration(milliseconds: 50));
        yield[];
        await Future.delayed(const Duration(milliseconds: 50));
        yield householdList;
      });

      final householdsState = HouseholdsState(
          inviteCodeRepository: inviteCodeRepo,
          householdRepository: householdRepo,
          currentUser: currentUser
      );
      var listenerCallCount = 0;
      householdsState.addListener(() => listenerCallCount++ );

      //wait for household stream
      await Future.delayed(const Duration(milliseconds: 200));

      expect(householdsState.households, householdList);
      expect(listenerCallCount, 2);
    });
  });
}