import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:grocery_manager/blogic/bloc/app/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Home'),
            ElevatedButton(
              child: const Text('Log out'),
              onPressed: (){
                context.read<AppBloc>().add(LogoutRequestedEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
