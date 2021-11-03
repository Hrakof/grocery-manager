import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:grocery_manager/screens/items/item_creation/item_creation_screen.dart';
import 'package:grocery_manager/screens/items/item_details/item_details_screen.dart';
import 'package:grocery_manager/widgets/confirm_delete_items_dialog.dart';
import 'package:grocery_manager/widgets/item_list.dart';
import 'package:provider/provider.dart';

class CartTab extends StatelessWidget {
  const CartTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HouseholdDetailsState>();
    return Stack(
      children: [
        state.cartItems == null ?
          const Center(
              child: CircularProgressIndicator(),
          )
            :
          ItemList(
            state.cartItems!,
            listKey: state.cartItemsListKey,
            checkedItemIds: state.selectedCartItemIds,
            onItemChecked: (item){
              state.itemChecked(item.id, ItemCollection.cart);
            },
            onItemTapped: (item){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                return ItemDetailsScreen(
                  householdId: state.household!.id,
                  itemCollection: ItemCollection.cart,
                  itemId: item.id,
                );
              }));
            },
          ),
        if(state.household != null)
          Positioned(
            bottom: 20,
            right: 30,
            child: FloatingActionButton(
              heroTag: 'add_fab',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ItemCreationScreen(
                  householdId: state.household!.id,
                  itemCollection: ItemCollection.cart,
                )));
              },
              child: const Icon(Icons.add),
            ),
          ),
        AnimatedPositioned(
          bottom: 90,
          right: state.selectedCartItemIds.isNotEmpty ? 30 : -60,
          duration: const Duration(milliseconds: 500),
          child: FloatingActionButton(
            heroTag: 'remove_fab',
            onPressed: () async {
              if(await showConfirmDeleteItemsDialog(context)){
                state.removeSelectedCartItems();
              }
            },
            child: const Icon(Icons.delete),
          ),
        ),
        AnimatedPositioned(
          bottom: 160,
          right: state.selectedCartItemIds.isNotEmpty ? 30 : -60,
          duration: const Duration(milliseconds: 500),
          child: FloatingActionButton(
            heroTag: 'move_fab',
            onPressed: () => state.moveSelectedCartItemsToFridge(),
            child: const Icon(Icons.arrow_forward),
          ),
        ),
      ],
    );
  }


}
