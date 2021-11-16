import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:grocery_manager/screens/items/item_creation/item_creation_screen.dart';
import 'package:grocery_manager/screens/items/item_details/item_details_screen.dart';
import 'package:grocery_manager/widgets/confirm_dialog.dart';
import 'package:grocery_manager/widgets/item_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:responsive_builder/responsive_builder.dart';

class FridgeTab extends StatelessWidget {
  const FridgeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final state = context.watch<HouseholdDetailsState>();
    return Stack(
      children: [
        state.fridgeItems == null ?
        const Center(
          child: CircularProgressIndicator(),
        )
            :
        ScreenTypeLayout(
          mobile: _buildItemList(state, context),
          tablet: _buildItemList(state, context,
              centerFlex: 3,
              placeHolderFlex: 1
          ),
          desktop: _buildItemList(state, context,
              centerFlex: 1,
              placeHolderFlex: 1
          ),
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
                  itemCollection: ItemCollection.fridge,
                )));
              },
              child: const Icon(Icons.add),
            ),
          ),
        AnimatedPositioned(
          bottom: 90,
          right: state.selectedFridgeItemIds.isNotEmpty ? 30 : -60,
          duration: const Duration(milliseconds: 500),
          child: FloatingActionButton(
            heroTag: 'remove_fab',
            onPressed: () async {
              if(await showConfirmDialog(context, title: l10n.confirmDeleteItemsTitle, message: l10n.confirmDeleteItemsMessage)){
                state.removeSelectedFridgeItems();
              }
            },
            child: const Icon(Icons.delete),
          ),
        ),
        AnimatedPositioned(
          bottom: 160,
          right: state.selectedFridgeItemIds.isNotEmpty ? 30 : -60,
          duration: const Duration(milliseconds: 500),
          child: FloatingActionButton(
            heroTag: 'move_fab',
            onPressed: () => state.moveSelectedFridgeItemsToCart(),
            child: const Icon(Icons.arrow_back),
          ),
        ),
      ],
    );
  }

  Widget _buildItemList(HouseholdDetailsState state, BuildContext context, {int placeHolderFlex = 0, int centerFlex = 1}){
    return Row(
      children: [
        Expanded(
            flex: placeHolderFlex,
            child: const SizedBox()
        ),
        Expanded(
          flex: centerFlex,
          child: ItemList(
            state.fridgeItems!,
            checkedItemIds: state.selectedFridgeItemIds,
            onItemChecked: (item){
              state.itemChecked(item.id, ItemCollection.fridge);
            },
            onItemTapped: (item){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                return ItemDetailsScreen(
                  householdId: state.household!.id,
                  itemCollection: ItemCollection.fridge,
                  itemId: item.id,
                );
              }));
            },
          ),
        ),
        Expanded(
            flex: placeHolderFlex,
            child: const SizedBox()
        ),
      ],
    );
  }
}