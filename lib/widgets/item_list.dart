import 'package:flutter/material.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:intl/intl.dart';

class ItemList extends StatelessWidget {
  const ItemList(this._items, {Key? key, required this.onItemChecked, required this.checkedItemIds}) : super(key: key);
  final List<Item> _items;
  final List<String> checkedItemIds;
  final Function(Item item) onItemChecked;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        return _ItemTile(_items[index],
            isChecked: checkedItemIds.contains(_items[index].id),
            onItemChecked: onItemChecked
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  _ItemTile(this._item, {required this.onItemChecked, Key? key, required this.isChecked}) : super(key: key);
  final Item _item;
  final bool isChecked;
  final DateFormat _formatter = DateFormat('MM-dd');
  final Function(Item item) onItemChecked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black),
        color: Colors.white38,
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (newValue){
              onItemChecked(_item);
            }
          ),
          Icon(_item.iconData),
          const SizedBox(width: 5),
          Text(_item.name),
          if(_item.amount != null) ...[
            const SizedBox(width: 5),
            Text(_item.amount.toString()),
          ],
          if(_item.unit != null) ...[
            const SizedBox(width: 5),
            Text(_item.unit!),
          ],
          if(_item.expirationDate != null) ...[
            const Icon(Icons.calendar_today),
            Text(_formatter.format(_item.expirationDate!)),
          ]

        ],
      )
    );
  }
}

