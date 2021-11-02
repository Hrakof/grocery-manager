import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:grocery_manager/blogic/provider/items/item_details_state.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:grocery_manager/widgets/rewritable_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String householdId;
  final String itemId;
  final ItemCollection itemCollection;

  const ItemDetailsScreen({required this.householdId, required this.itemId, required this.itemCollection, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (BuildContext context) => ItemDetailsState(
          householdId: householdId,
          itemId: itemId,
          itemCollection: itemCollection,
          itemRepository: context.read<ItemRepository>(),
      ),
      child: const _ItemDetailsScreenContent(),
    );
  }
}

class _ItemDetailsScreenContent extends StatelessWidget {
  const _ItemDetailsScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ItemDetailsState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(state.item == null ? '...' : state.item!.name),
      ),
      body: state.item == null ?
        const CircularProgressIndicator()
          :
        ItemDetails(state.item!),
    );
  }
}


class ItemDetails extends StatelessWidget {
  final Item item;

  const ItemDetails( this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _IconRow(item.iconData)
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: _NameRow(item.name)
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: _AmountRow(item.amount)
        ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _UnitRow(item.unit)
        ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _DescriptionRow(item.description)
        ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _ExpirationDateRow(item.expirationDate)
        ),
      ],
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow(this.name, {Key? key}) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return RewritableText(
      text: Text(name),
      onTextEdited: (newName) {
        if(newName.length < 3){
          final snackBar = SnackBar(content: Text(l10n.tooShort));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }else{
          context.read<ItemDetailsState>().changeName(newName);
        }
      },
      labelText: l10n.nameLabel,
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(this.amount, {Key? key}) : super(key: key);

  final double? amount;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return RewritableText(
      text: Text(amount?.toString() ?? '-'),
      onTextEdited: (newAmount){
        double number;
        try{
          number = double.parse(newAmount);
        } on FormatException {
          final snackBar = SnackBar(content: Text(l10n.notANumber));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
        if(number < 0.0){
          final snackBar = SnackBar(content: Text(l10n.cantBeNegative));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }else{
          context.read<ItemDetailsState>().changeAmount(number);
        }
      },
      labelText: l10n.amountLabel,
      textInputType: TextInputType.number,
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow(this.unit, {Key? key}) : super(key: key);

  final String? unit;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return RewritableText(
      text: Text(unit ?? '-'),
      onTextEdited: (newUnit) {
        if(newUnit.length > 5){
          final snackBar = SnackBar(content: Text(l10n.tooLong));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }else{
          context.read<ItemDetailsState>().changeUnit(newUnit);
        }
      },
      labelText: l10n.unitLabel,
    );
  }
}

class _DescriptionRow extends StatelessWidget {
  const _DescriptionRow(this.description, {Key? key}) : super(key: key);

  final String? description;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return RewritableText(
      text: Text(description ?? '-'),
      onTextEdited: (newDescription) {
        if(newDescription.length > 150){
          final snackBar = SnackBar(content: Text(l10n.tooLong));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }else{
          context.read<ItemDetailsState>().changeDescription(newDescription);
        }
      },
      labelText: l10n.descriptionLabel,
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow(this.iconData, {Key? key}) : super(key: key);

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () async {
            final selectedIcon = await FlutterIconPicker.showIconPicker(context);
            if (selectedIcon != null) {
              context.read<ItemDetailsState>().changeIcon(selectedIcon);
            }
          },
          icon: const Icon(Icons.edit)
        )
      ],
    );
  }
}

class _ExpirationDateRow extends StatelessWidget {
  const _ExpirationDateRow(this.expirationDate, {Key? key}) : super(key: key);

  final DateTime? expirationDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(expirationDate == null ? '-' : DateFormat('yyyy-MM-dd').format(expirationDate!)),
        IconButton(
            onPressed: () async {
              final today = DateTime.now();
              final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: today,
                  firstDate: today,
                  lastDate: DateTime(3000)
              );
              if (selectedDate != null) {
                context.read<ItemDetailsState>().changeExpirationDate(selectedDate);
              }
            },
            icon: const Icon(Icons.edit)
        )
      ],
    );
  }
}

