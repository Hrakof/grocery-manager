import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

enum _MenuOptions {logOut}

class OptionsMenu extends StatelessWidget{
  const OptionsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return PopupMenuButton(
      icon: const Icon(Icons.menu),
      itemBuilder: (context){
        return [
          PopupMenuItem(
            value: _MenuOptions.logOut,
            child: Text(l10n.logOutMenuItemText),
          ),
        ];
      },
      onSelected: (selected){
        switch (selected){
          case _MenuOptions.logOut:
            context.read<AppBloc>().add(LogoutRequestedEvent());
            break;
        }
      },
    );
  }

}