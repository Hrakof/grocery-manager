import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
      ),
      body: const Center(
        child: Text('Home'),
      ),
    );
  }
}
