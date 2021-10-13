import 'package:flutter/material.dart';
import 'package:grocery_manager/models/item/item.dart';

class ItemList extends StatelessWidget {
  const ItemList(this._items, {Key? key}) : super(key: key);
  final List<Item> _items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        return _ItemTile(_items[index]);
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile(this._item, {Key? key}) : super(key: key);
  final Item _item;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(_item.name),
    );
  }
}

