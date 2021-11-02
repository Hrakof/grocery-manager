import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:grocery_manager/screens/items/item_creation/item_creation_screen.dart';
import 'package:grocery_manager/screens/items/item_details/item_details_screen.dart';
import 'package:grocery_manager/widgets/item_list.dart';
import 'package:provider/provider.dart';

class FridgeTab extends StatelessWidget {
  const FridgeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HouseholdDetailsState>();
    return Stack(
      children: [
        state.fridgeItems == null ?
        const Center(
          child: CircularProgressIndicator(),
        )
            :
        ItemList(
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
        Selector<HouseholdDetailsState, Household?>(
          selector: (_, state) => state.household,
          builder: (_, household, __){
            if(household != null) {
              return Positioned(
                bottom: 40,
                right: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ItemCreationScreen(
                      householdId: household.id,
                      itemCollection: ItemCollection.fridge,
                    )));
                  },
                  child: const Icon(Icons.add),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}