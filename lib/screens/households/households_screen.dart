import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_manager/blogic/provider/households/households_state.dart';
import 'package:grocery_manager/repositories/household/household_repository.dart';
import 'package:grocery_manager/screens/household_details/household_details_screen.dart';
import 'package:grocery_manager/widgets/options_menu.dart';
import 'package:provider/provider.dart';

class HouseholdsScreen extends StatelessWidget {
  const HouseholdsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final user = (context.read<AppBloc>().state as AuthenticatedAppState).currentUser;

    return ChangeNotifierProvider(
      create: (BuildContext context) => HouseholdsState(householdRepository: context.read<HouseholdRepository>(), currentUser: user),
      builder: (context, _){
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.houseHoldsScreenTitle),
            actions: const [
              OptionsMenu(),
              SizedBox(width: 20),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){ _createHouseholdWithDialog(context); },
            child: const Icon(Icons.add),
          ),
          body: DoubleBackToCloseApp(
            snackBar: SnackBar(content: Text(l10n.tapBackAgainToLeave)),
            child: Center(
              child: Column(
                children: const [
                  Text('Households'),
                  _HouseholdList(),
                ],
              ),
            ),
          ),
        );
      },
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
      context.read<HouseholdsState>().createHousehold( result);
    }
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
        itemCount: households.length,
        shrinkWrap: true,
        itemBuilder: (context, idx){
          final household = households[idx];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => HouseholdDetailsScreen(household: household)
            )),
            child: Center(
              child: Text(household.name)
            )
          );
        }
      );
    }
  }
}
