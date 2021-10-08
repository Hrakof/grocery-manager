import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/screens/household_details/tabs/cart_tab.dart';
import 'package:grocery_manager/screens/household_details/tabs/fridge_tab.dart';
import 'package:grocery_manager/screens/household_details/tabs/members_tab.dart';
import 'package:grocery_manager/widgets/options_menu.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';


class HouseholdDetailsScreen extends StatelessWidget {

  final Household _selectedHouseHold;
  const HouseholdDetailsScreen({required Household household, Key? key}):
      _selectedHouseHold = household,
      super(key: key);


  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selectedHouseHold.name),
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
        body: Provider(
          create: (BuildContext context) => HouseholdDetailsState(_selectedHouseHold),
          child: const TabBarView(
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


