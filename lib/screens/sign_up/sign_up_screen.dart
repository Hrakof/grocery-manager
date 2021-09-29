import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/bloc/authentication/formz_inputs/verify_password.dart';
import 'package:grocery_manager/blogic/bloc/authentication/signup/sign_up_cubit.dart';
import 'package:grocery_manager/repositories/authentication/authentication_repository.dart';

class SignUpScreen extends StatelessWidget{
  const SignUpScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up'),),
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
    return BlocListener<SignUpCubit, SignUpState>(
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
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<SignUpCubit>().emailChanged(value); },
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

class _DisplayNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<SignUpCubit>().displayNameChanged(value); },
          decoration: InputDecoration(
            icon: const Icon(Icons.book), //TODO jobb icon
            labelText: 'Display name',
            helperText: '',
            errorText: state.displayName.invalid ? 'Invalid name' : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<SignUpCubit>().passwordChanged(value); },
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

class _VerifyPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state){
        return TextField(
          onChanged: (value){ context.read<SignUpCubit>().verifyPasswordChanged(value); },
          obscureText: true,
          decoration: InputDecoration(
            icon: const Icon(Icons.lock),
            labelText: 'Password again',
            helperText: '',
            errorText: state.verifyPassword.invalid ? _getErrorMessage(state.verifyPassword) : null,
          ),
        );
      },
    );
  }

  String _getErrorMessage( VerifyPassword verifyPassword ){
    switch(verifyPassword.error){
      case PasswordVerificationError.doesNotMatch:
        return "Passwords don't match";
      case null:
        return '';
    }
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.status.isValid ? () { context.read<SignUpCubit>().signUp(); } : null,
          child: const Text('SIGN UP'),
        );
      },
    );
  }
}
