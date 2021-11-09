import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_manager/blogic/provider/households/households_state.dart';
import 'package:grocery_manager/models/household/household.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';
import 'package:grocery_manager/repositories/invite_code/invite_code_repository.dart';
import 'package:grocery_manager/widgets/options_menu.dart';
import 'package:provider/provider.dart';

import 'household_details/household_details_screen.dart';

class HouseholdsScreen extends StatelessWidget {
  const HouseholdsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final user = (context.read<AppBloc>().state as AuthenticatedAppState).currentUser;

    return ChangeNotifierProvider(
      create: (BuildContext context) => HouseholdsState(
          householdRepository: context.read<HouseholdRepository>(),
          inviteCodeRepository: context.read<InviteCodeRepository>(),
          currentUser: user
      ),
      builder: (context, _){
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.houseHoldsScreenTitle),
            actions: const [
              OptionsMenu(),
              SizedBox(width: 20),
            ],
          ),
          body: DoubleBackToCloseApp(
            snackBar: SnackBar(content: Text(l10n.tapBackAgainToLeave)),
            child: const _HouseholdList(),
          ),
        );
      },
    );
  }
}

class _HouseholdList extends StatelessWidget {
  const _HouseholdList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final households = context.watch<HouseholdsState>().households;
    if(households == null) {
      return const CircularProgressIndicator();
    }
    else{
      return ListView.builder(
        itemCount: households.length + 1,
        shrinkWrap: true,
        itemBuilder: (context, idx){
          if(idx == households.length){
            return const _AddOrCreateTile();
          }
          final household = households[idx];
          return _HouseholdTile(household: household);
        }
      );
    }
  }
}

class _HouseholdTile extends StatelessWidget {
  final Household household;

  const _HouseholdTile({required this.household, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => HouseholdDetailsScreen(householdId: household.id)
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.black),
          color: Colors.amber[200]
        ),
        child: Center(child: Text(household.name))
      ),
    );
  }
}

class _AddOrCreateTile extends StatelessWidget {
  const _AddOrCreateTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black),
          color: Colors.amber[200]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _createHouseholdWithDialog(context),
            child: Text(l10n.create)
          ),
          ElevatedButton(
              onPressed: () => _joinHouseholdWithDialog(context),
              child: Text(l10n.join)
          ),
        ],
      ),
    );
  }

  void _createHouseholdWithDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final l10n = L10n.of(context)!;
    final result = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.createHouseHoldDialogTitle),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              icon: const Icon(Icons.home),
              labelText: l10n.nameLabel,
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: (){ Navigator.pop(context, nameController.text ); },
                child: const Text('OK')
            ),
            ElevatedButton(
                onPressed: (){ Navigator.pop(context, null ); },
                child: Text(l10n.cancelButtonText)
            ),
          ],
        );
      },
    );

    if(result != null){
      context.read<HouseholdsState>().createHousehold(result);
    }
  }

  void _joinHouseholdWithDialog(BuildContext context) async {
    final inviteCodeController = TextEditingController();
    final l10n = L10n.of(context)!;
    final result = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.joinHouseHoldDialogTitle),
          content: TextField(
            controller: inviteCodeController,
            decoration: InputDecoration(
              icon: const Icon(Icons.lock),
              labelText: l10n.inviteCode,
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: (){ Navigator.pop(context, inviteCodeController.text ); },
                child: const Text('OK')
            ),
            ElevatedButton(
                onPressed: (){ Navigator.pop(context, null ); },
                child: Text(l10n.cancelButtonText)
            ),
          ],
        );
      },
    );

    if(result != null){
      try{
        await context.read<HouseholdsState>().joinHousehold(result);
      }
      on InvalidInviteCodeException catch (exception){
        final snackBar = SnackBar(content: Text('${l10n.invalidInviteCode}: ${exception.inviteCode}'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      on HouseholdDoesNotExistException {
        final snackBar = SnackBar(content: Text(l10n.houseHoldDoesNotExist));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      on AlreadyMemberException {
        final snackBar = SnackBar(content: Text(l10n.alreadyMember));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}

