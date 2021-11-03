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

  Future<void> moveItems(String householdId, ItemCollection fromItemCollection, ItemCollection toItemCollection, List<Item> items) async {

    final List<DocumentReference> fromDocs = [];
    final List<DocumentReference> toDocs = [];

    final householdDoc =  FirebaseFirestore.instance.collection('households').doc(householdId);

    for(final item in items){
      fromDocs.add(householdDoc.collection(fromItemCollection.getCollectionName()).doc(item.id));
      toDocs.add(householdDoc.collection(toItemCollection.getCollectionName()).doc(item.id));
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      for(final docRef in fromDocs){
        transaction.delete(docRef);
      }
      toDocs.asMap().forEach((index, docRef) {
        transaction.set(docRef, items[index].toJson());
      });
    });
  }

  Future<void> deleteItems(String householdId, ItemCollection itemCollection, List<Item> items) async {
    final List<DocumentReference> docRefs = [];

    for(final item in items){
      docRefs.add(_getCollectionReference(householdId, itemCollection).doc(item.id));
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      for(final docRef in docRefs){
        transaction.delete(docRef);
      }
    });
  }

  Future<void> updateItem(String householdId, ItemCollection itemCollection, Item item) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docRef = _getCollectionReference(householdId, itemCollection).doc(item.id);
      transaction.set(docRef, item);
    });
  }

  Stream<Item> itemStream(String householdId, ItemCollection itemCollection, String itemId) {
    return _getCollectionReference(householdId, itemCollection)
        .doc(itemId)
        .snapshots()
        .map( (snapshot) =>snapshot.data()! );
  }

}