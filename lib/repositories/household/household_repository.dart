
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_manager/models/household/household.dart';

class HouseholdRepository {


  final CollectionReference<Household> _householdCollection = FirebaseFirestore.instance
      .collection('households').withConverter<Household>(
    fromFirestore: (snapshot, _) => Household.fromJson(snapshot.data()!),
    toFirestore: (household, _) => household.toJson(),
  );

  Stream<Household> householdStream(String id) {
    return _householdCollection
        .doc(id)
        .snapshots()
        .map( (snapshot) =>snapshot.data()! );
  }

  Future<void> updateHousehold(Household household) async {
    final docRef = _householdCollection.doc(household.id);
    await docRef.set(household);
  }

  Future<Household> getUser(String uid) async {
    final snapshot = await _householdCollection.doc(uid).get();
    return snapshot.data()!;
  }
}