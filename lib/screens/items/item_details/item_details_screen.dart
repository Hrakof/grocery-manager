import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/provider/items/item_details_state.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:grocery_manager/widgets/rewritable_text.dart';
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
    final l10n = L10n.of(context)!;
    return Column(
      children: [
        RewritableText(
          text: Text(item.name),
          onTextEdited: (newName) {
            if(newName.length < 3){
              final snackBar = SnackBar(content: Text(l10n.tooShort));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }else{
              context.read<ItemDetailsState>().changeName(newName);
            }
          },
          labelText: l10n.nameLabel,
        ),
      ],
    );
  }
}



























