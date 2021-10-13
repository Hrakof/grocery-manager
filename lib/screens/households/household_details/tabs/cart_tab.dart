import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/models/item/item.dart';
import 'package:grocery_manager/screens/items/item_creation/item_creation_screen.dart';
import 'package:grocery_manager/widgets/item_list.dart';
import 'package:provider/provider.dart';

class CartTab extends StatelessWidget {
  const CartTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Selector<HouseholdDetailsState, List<Item>?>(
          selector: (_, state) => state.cartItems,
          builder: (_, cartItems, __){
            if(cartItems == null){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ItemList(cartItems);
          },
        ),
        Positioned(
          bottom: 40,
          right: 30,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemCreationScreen()) );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
