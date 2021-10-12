import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_manager/models/item/item.dart';

enum  ItemCollection{
  cart,
  fridge
}

extension _ToName on ItemCollection{
  String getCollectionName() {
    return toString().split('.').last;
  }
}
class ItemRepository{

  CollectionReference<Item> _getCollectionReference(String householdId, ItemCollection itemCollection){
    return FirebaseFirestore.instance
        .collection('households').doc(householdId).collection(itemCollection.getCollectionName()).withConverter<Item>(
        fromFirestore: (snapshot, _) => Item.fromJson(snapshot.data()!),
        toFirestore: (item, _) => item.toJson(),
    );
  }

  Stream<List<Item>> itemListStream(String householdId, ItemCollection itemCollection) {
    final collectionRef = _getCollectionReference(householdId, itemCollection);
    return collectionRef
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((docSnapshot) =>
            docSnapshot.data()
        ).toList()
    );
  }

  Future<void> updateItem(String householdId, ItemCollection itemCollection, Item item) async {
    final docRef = _getCollectionReference(householdId, itemCollection).doc(item.id);
    await docRef.set(item);
  }

  Stream<Item> itemStream(String householdId, ItemCollection itemCollection, String itemId) {
    return _getCollectionReference(householdId, itemCollection)
        .doc(itemId)
        .snapshots()
        .map( (snapshot) =>snapshot.data()! );
  }

}