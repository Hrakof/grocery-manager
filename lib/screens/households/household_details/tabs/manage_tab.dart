import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:grocery_manager/blogic/provider/households/household_details_state.dart';
import 'package:grocery_manager/widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ManageTab extends StatelessWidget {
  const ManageTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HouseholdDetailsState>();

    if(state.household == null){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: ScreenTypeLayout(
        breakpoints: const ScreenBreakpoints(
            tablet: 600,
            desktop: 950,
            watch: 300
        ),
        mobile: _buildContentColumn(state, context),
        tablet: _buildContentColumn(state, context,
            centerFlex: 3,
            placeHolderFlex: 1
        ),
        desktop: _buildContentColumn(state, context,
            centerFlex: 2,
            placeHolderFlex: 1
        ),
      ),
    );
  }

  Widget _buildContentColumn(HouseholdDetailsState state, BuildContext context, {int placeHolderFlex = 0, int centerFlex = 1}){
    final currentUserId = (context.read<AppBloc>().state as AuthenticatedAppState).currentUser.id;
    final l10n = L10n.of(context)!;
    final userIsTheOwner = state.household!.ownerUid == currentUserId;

    return Row(
      children: [
        Expanded(
            flex: placeHolderFlex,
            child: const SizedBox()
        ),
        Expanded(
          flex: centerFlex,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                child: Text('${l10n.inviteCode}: ${state.inviteCode}',
                  style: TextStyle(fontSize: 24.sp),
                ),
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
                        child: Text(l10n.delete,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: !userIsTheOwner ? () async {
                          if(await showConfirmDialog(context, title: l10n.leave, message: l10n.confirmLeaveHouseholdMessage)){
                            state.leaveHousehold(currentUserId);
                          }
                        }: null,
                        child: Text(l10n.leave,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                    ],
                  )
              ),
              ExpansionTile(
                title: Text(
                  l10n.members,
                  style: TextStyle(
                    fontSize: 20.sp,
                  ),
                ),
                children: state.members.map((member) {
                  return ListTile(
                    title: Text(member.displayName,
                      style: TextStyle(
                        fontSize: 18.sp,
                      ),
                    ),
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
        ),
        Expanded(
            flex: placeHolderFlex,
            child: const SizedBox()
        ),
      ],
    );
  }
}