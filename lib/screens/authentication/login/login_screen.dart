import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/bloc/authentication/login/login_cubit.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';
import 'package:grocery_manager/screens/authentication/sign_up/sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle),),
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(content: Text(l10n.tapBackAgainToLeave)),
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
    final media = MediaQuery.of(context);

    final centerFlex =      media.size.width < 600 ? 1 : media.size.width < 1000 ? 3 : media.size.width < 1500 ? 1 : 1;
    final placeHolderFlex = media.size.width < 600 ? 0 : media.size.width < 1000 ? 1 : media.size.width < 1500 ? 1 : 2;

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state){
        if(state.status == FormzStatus.submissionFailure){
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage),));
        }
      },
      child: Center(
        child: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                flex: placeHolderFlex,
                child: const SizedBox(),
              ),
              Expanded(
                flex: centerFlex,
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
              Expanded(
                flex: placeHolderFlex,
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<LoginCubit>().emailChanged(value); },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            icon: const Icon(Icons.email),
            labelText: l10n.emailLabel,
            helperText: '',
            errorText: state.email.invalid ? l10n.invalidEmail : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<LoginCubit>().passwordChanged(value); },
          obscureText: true,
          decoration: InputDecoration(
            icon: const Icon(Icons.lock),
            labelText: l10n.passwordLabel,
            helperText: '',
            errorText: state.password.invalid ? l10n.invalidPassword : null,
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return BlocBuilder<LoginCubit, LoginState>(
        buildWhen: (previousState, state){ return previousState.status != state.status; },
        builder: (context, state){
          return ElevatedButton(
            onPressed: state.status.isValidated ? (){ context.read<LoginCubit>().login(); } : null,
            child: Text(l10n.loginButtonText),
          );
        }
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return ElevatedButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return const SignUpScreen();
        }));
      },
      child: Text(l10n.signUpButtonText),
    );
  }
}