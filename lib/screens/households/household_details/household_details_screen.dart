import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:grocery_manager/screens/households/household_details/tabs/cart_tab.dart';
import 'package:grocery_manager/screens/households/household_details/tabs/fridge_tab.dart';
import 'package:grocery_manager/screens/households/household_details/tabs/members_tab.dart';
import 'package:grocery_manager/widgets/options_menu.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';


class HouseholdDetailsScreen extends StatelessWidget {

  final String _selectedHouseHoldId;
  const HouseholdDetailsScreen({required String householdId, Key? key}):
        _selectedHouseHoldId = householdId,
      super(key: key);


  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return DefaultTabController(
      length: 3,
      child: ChangeNotifierProvider(
        create: (BuildContext context) => HouseholdDetailsState(
            householdId: _selectedHouseHoldId,
            householdRepository: context.read<HouseholdRepository>(),
            itemRepository: context.read<ItemRepository>()
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Selector<HouseholdDetailsState, String>(
              selector: (_, state) => state.household?.name ?? l10n.unknownHouseholdName,
              builder: (_, name, __) => Text(name),
            ),
            actions: const [
              OptionsMenu(),
              SizedBox(width: 20),
            ],
            bottom: TabBar(
              tabs: [
                Tab(text: l10n.cartTabTitle),
                Tab(text: l10n.fridgeTabTitle),
                Tab(text: l10n.membersTabTitle),
              ],
            ),
          ),
          body: const TabBarView(
            //physics: const NeverScrollableScrollPhysics(),
            children: [
              CartTab(),
              FridgeTab(),
              MembersTab(),
            ],
          ),
        ),
      ),
    );
  }
}


