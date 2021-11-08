import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

Future<bool> showConfirmDialog(BuildContext context, {required final String title, required final String message}) async {
  final l10n = L10n.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
              onPressed: (){ Navigator.pop(context,true ); },
              child: Text(l10n.yes)
          ),
          ElevatedButton(
              onPressed: (){ Navigator.pop(context, false ); },
              child: Text(l10n.no)
          ),
        ],
      );
    },
  );
  return result ?? false;
}