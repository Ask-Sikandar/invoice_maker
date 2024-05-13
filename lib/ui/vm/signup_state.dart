

import 'package:equatable/equatable.dart';

class SignUpState extends Equatable{
  const SignUpState();

  @override
  List<Object> get props => [];

}

class SignUpStateInitial extends SignUpState{
  const SignUpStateInitial();

  @override
  List<Object> get props => [];

}

class SignUpStateLoading extends SignUpState{
  const SignUpStateLoading();

  @override
  List<Object> get props => [];

}

class SignUpStateSuccess extends SignUpState{
  const SignUpStateSuccess();

  @override
  List<Object> get props => [];

}
class SignUpStateError extends SignUpState{
  final String error;
  const SignUpStateError(this.error);

  @override
  List<Object> get props => [error];

}