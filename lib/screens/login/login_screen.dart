import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(content: Text('Tap back again to leave')),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Flex(
              direction: Axis.vertical,
              children:[Expanded(child: _LoginForm())]
          ),
        ),
      ),
    );
  }

}

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            'assets/images/firebase_logo.png',
            scale: 3,
          ),
          _EmailInput(),
          const SizedBox(height: 8.0),
          _LoginButton(),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
        onChanged: (value){  },
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          icon: Icon(Icons.email),
          labelText: 'Email',
          helperText: '',
        ),
    );
  }
}


class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('LOGIN'),
    );
  }
}