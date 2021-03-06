
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_manager/models/user/user.dart';

class UserRepository {


  final CollectionReference<User> _userCollection = FirebaseFirestore.instance
      .collection('users').withConverter<User>(
    fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );

  Stream<User> getUserStream(String uid) {
    return _userCollection
      .doc(uid)
      .snapshots()
      .map( (snapshot) =>snapshot.data()! );
  }

  Future<void> updateUser(User user) async {
    final userDoc = _userCollection.doc(user.id);
    await userDoc.set(user);
  }

  Future<User?> getUser(String uid) async {
    final snapshot = await _userCollection.doc(uid).get();
    return snapshot.data();
  }
}