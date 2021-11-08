import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/repositories/repositories.dart';
import 'package:grocery_manager/screens/households/household_details/tabs/cart_tab.dart';
import 'package:grocery_manager/screens/households/household_details/tabs/fridge_tab.dart';
import 'package:grocery_manager/screens/households/household_details/tabs/manage_tab.dart';
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
            inviteCodeRepository: context.read<InviteCodeRepository>(),
            itemRepository: context.read<ItemRepository>(),
            userRepository: context.read<UserRepository>(),
        ),
        child: Consumer<HouseholdDetailsState>(
          builder: (context, state, child){
            if(state.household != null){
              final currentUserId = (context.read<AppBloc>().state as AuthenticatedAppState).currentUser.id;
              if(state.householdDeleted || !state.household!.memberUids.contains(currentUserId)){
                SchedulerBinding.instance!.addPostFrameCallback((_) {
                  Navigator.of(context).pop();
                });
              }
            }
            return child!;
          },
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
                  Tab(text: l10n.manageTabTitle),
                ],
              ),
            ),
            body: const TabBarView(
              //physics: const NeverScrollableScrollPhysics(),
              children: [
                CartTab(),
                FridgeTab(),
                ManageTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


