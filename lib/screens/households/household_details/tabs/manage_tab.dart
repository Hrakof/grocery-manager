import 'package:flutter/material.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ManageTab extends StatelessWidget {
  const ManageTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HouseholdDetailsState>();
    final currentUserId = (context.read<AppBloc>().state as AuthenticatedAppState).currentUser.id;
    final l10n = L10n.of(context)!;

    if(state.household == null){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final userIsTheOwner = state.household!.ownerUid == currentUserId;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: Text('${l10n.inviteCode}: ${state.inviteCode}'),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: userIsTheOwner ? () async {
                    if(await showConfirmDialog(context, title: l10n.delete, message: l10n.confirmDeleteHouseholdMessage)){
                      state.deleteHousehold(currentUserId);
                    }
                  } : null,
                  child: Text(l10n.delete),
                ),
                ElevatedButton(
                  onPressed: !userIsTheOwner ? () async {
                    if(await showConfirmDialog(context, title: l10n.leave, message: l10n.confirmLeaveHouseholdMessage)){
                      state.leaveHousehold(currentUserId);
                    }
                  }: null,
                  child: Text(l10n.leave),
                ),
              ],
            )
          ),
          ExpansionTile(
            title: Text(
              l10n.members,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            children: state.members.map((member) {
              return ListTile(
                title: Text(member.displayName),
                trailing: userIsTheOwner && member.id != currentUserId ? IconButton(
                  onPressed: () async {
                    if(await showConfirmDialog(context, title: l10n.kick, message: l10n.confirmKickMessage)){
                      state.kickMember(member.id);
                    }
                  },
                  icon: const Icon(Icons.person_remove)
                ) : null,
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}