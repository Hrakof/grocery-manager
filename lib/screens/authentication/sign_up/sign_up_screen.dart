import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/bloc/authentication/formz_inputs/verify_password.dart';
import 'package:grocery_manager/blogic/bloc/authentication/signup/sign_up_cubit.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';

class SignUpScreen extends StatelessWidget{
  const SignUpScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signUpTitle),),
      body: BlocProvider(
        create: (_) => SignUpCubit( context.read<AuthenticationRepository>() ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Flex(
              direction: Axis.vertical,
              children:[Expanded(child: _SignUpForm())]
          ),
        ),
      ),
    );
  }

}

class _SignUpForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final centerFlex =      media.size.width < 600 ? 1 : media.size.width < 1000 ? 3 : media.size.width < 1500 ? 1 : 1;
    final placeHolderFlex = media.size.width < 600 ? 0 : media.size.width < 1000 ? 1 : media.size.width < 1500 ? 1 : 2;

    return BlocListener<SignUpCubit, SignUpState>(
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
                    _EmailInput(),
                    const SizedBox(height: 8.0),
                    _DisplayNameInput(),
                    const SizedBox(height: 8.0),
                    _PasswordInput(),
                    const SizedBox(height: 8.0),
                    _VerifyPasswordInput(),
                    const SizedBox(height: 8.0),
                    _SignUpButton(),
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
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<SignUpCubit>().emailChanged(value); },
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

class _DisplayNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<SignUpCubit>().displayNameChanged(value); },
          decoration: InputDecoration(
            icon: const Icon(Icons.book),
            labelText: l10n.displayNameLabel,
            helperText: '',
            errorText: state.displayName.invalid ? l10n.invalidDisplayName : null,
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
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<SignUpCubit>().passwordChanged(value); },
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

class _VerifyPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<SignUpCubit>().verifyPasswordChanged(value); },
          obscureText: true,
          decoration: InputDecoration(
            icon: const Icon(Icons.lock),
            labelText: l10n.passwordAgainLabel,
            helperText: '',
            errorText: state.verifyPassword.invalid ? _getErrorMessage(l10n, state.verifyPassword) : null,
          ),
        );
      },
    );
  }

  String _getErrorMessage(L10n l10n, VerifyPassword verifyPassword ){
    switch(verifyPassword.error){
      case PasswordVerificationError.doesNotMatch:
        return l10n.passwordsDontMatch;
      case null:
        return '';
    }
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.status.isValid ? () { context.read<SignUpCubit>().signUp(); } : null,
          child: Text(l10n.signUpButtonText),
        );
      },
    );
  }
}
