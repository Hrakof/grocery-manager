import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_manager/models/invite_code/invite_code.dart';

class InviteCodeRepository {

  final CollectionReference<InviteCode> _inviteCodeCollection = FirebaseFirestore.instance
      .collection('invite_codes').withConverter<InviteCode>(
    fromFirestore: (snapshot, _) => InviteCode.fromJson(snapshot.data()!),
    toFirestore: (inviteCode, _) => inviteCode.toJson(),
  );

  Future<bool> createInviteCode(InviteCode newInviteCode) async {
    if(await getInviteCodeByValue(newInviteCode.value) != null){
      return false;
    }
    try{
      await _inviteCodeCollection.doc(newInviteCode.value).set(newInviteCode);
      return true;
    } on Exception {
      return false;
    }
  }
  
  Future<InviteCode?> getInviteCodeByValue(String value) async {
    final docSnapshot = await _inviteCodeCollection
        .doc(value)
        .get();

    return docSnapshot.data();
  }
  
  Future<InviteCode?> getInviteCodeOfHousehold(String householdId) async {
    final querySnapshot = await _inviteCodeCollection
      .where('household_id', isEqualTo: householdId)
      .get();
    if(querySnapshot.docs.isEmpty) return null;

    final inviteCodes = querySnapshot.docs.map((docSnapshot) => docSnapshot.data());
    return _getLatestInviteCode(inviteCodes);
  }

  InviteCode _getLatestInviteCode(Iterable<InviteCode> inviteCodes){
    InviteCode result = inviteCodes.first;
    for (var inviteCode in inviteCodes) {
      if(inviteCode.creationDate.compareTo(result.creationDate) < 0){
        result = inviteCode;
      }
    }
    return result;
  }
}