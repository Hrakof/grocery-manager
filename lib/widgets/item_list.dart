import 'package:flutter/material.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:intl/intl.dart';

class ItemList extends StatelessWidget {
  const ItemList(this._items, {Key? key, this.onItemChecked, required this.checkedItemIds, this.onItemTapped, this.listKey}) : super(key: key);
  final List<Item> _items;
  final List<String> checkedItemIds;
  final Function(Item item)? onItemChecked;
  final Function(Item item)? onItemTapped;
  final GlobalKey<AnimatedListState>? listKey;

  @override
  Widget build(BuildContext context) {
    if(listKey == null){
      return ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          return ItemTile(
            _items[index],
            isChecked: checkedItemIds.contains(_items[index].id),
            onItemChecked: onItemChecked,
            onItemTapped: onItemTapped,
          );
        },
      );
    } else {
      return AnimatedList(
        key: listKey,
        initialItemCount: _items.length,
        itemBuilder: (context, index, animation) {
          return ItemTile(
            _items[index],
            isChecked: checkedItemIds.contains(_items[index].id),
            onItemChecked: onItemChecked,
            onItemTapped: onItemTapped,
          );
        },
      );
    }

  }
}

class ItemTile extends StatelessWidget {
  ItemTile(this._item, {this.onItemChecked, Key? key, required this.isChecked, this.onItemTapped}) : super(key: key);
  final Item _item;
  final bool isChecked;
  final DateFormat _formatter = DateFormat('MM-dd');
  final Function(Item item)? onItemChecked;
  final Function(Item item)? onItemTapped;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (){
            onItemTapped?.call(_item);
          },
          child: Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (newValue){
                  onItemChecked?.call(_item);
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
                const SizedBox(width: 10),
                const Icon(Icons.calendar_today),
                Text(_formatter.format(_item.expirationDate!)),
              ]

            ],
          ),
        ),
      )
    );
  }
}

