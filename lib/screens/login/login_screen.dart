import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/bloc/authentication/login/login_cubit.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';
import 'package:grocery_manager/screens/sign_up/sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle),),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(content: Text('Tap back again to leave')),
        child: BlocProvider(
          create: (_) => LoginCubit( context.read<AuthenticationRepository>() ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Flex(
                direction: Axis.vertical,
                children:[Expanded(child: _LoginForm())]
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state){
        if(state.status == FormzStatus.submissionFailure){
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage),));
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/firebase_logo.png',
              scale: 3,
            ),
            _EmailInput(),
            const SizedBox(height: 8.0),
            _PasswordInput(),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SignUpButton(),
                _LoginButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<LoginCubit>().emailChanged(value); },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            icon: const Icon(Icons.email),
            labelText: 'Email',
            helperText: '',
            errorText: state.email.invalid ? 'Invalid email' : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<LoginCubit>().passwordChanged(value); },
          obscureText: true,
          decoration: InputDecoration(
            icon: const Icon(Icons.lock),
            labelText: 'Password',
            helperText: '',
            errorText: state.password.invalid ? 'Invalid password' : null,
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
        buildWhen: (previousState, state){ return previousState.status != state.status; },
        builder: (context, state){
          return ElevatedButton(
            onPressed: state.status.isValidated ? (){ context.read<LoginCubit>().login(); } : null,
            child: const Text('LOGIN'),
          );
        }
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return const SignUpScreen();
        }));
      },
      child: const Text('SIGN UP'),
    );
  }
}