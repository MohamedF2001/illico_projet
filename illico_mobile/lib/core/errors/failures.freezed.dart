// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Failure {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverError,
    required TResult Function() networkError,
    required TResult Function() unauthorized,
    required TResult Function() notFound,
    required TResult Function(Map<String, dynamic> errors) validationError,
    required TResult Function() unexpectedError,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverError,
    TResult? Function()? networkError,
    TResult? Function()? unauthorized,
    TResult? Function()? notFound,
    TResult? Function(Map<String, dynamic> errors)? validationError,
    TResult? Function()? unexpectedError,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverError,
    TResult Function()? networkError,
    TResult Function()? unauthorized,
    TResult Function()? notFound,
    TResult Function(Map<String, dynamic> errors)? validationError,
    TResult Function()? unexpectedError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

class _$ServerError implements ServerError {
  const _$ServerError({this.message});
  @override final String? message;

  @override
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverError,
    required TResult Function() networkError,
    required TResult Function() unauthorized,
    required TResult Function() notFound,
    required TResult Function(Map<String, dynamic> errors) validationError,
    required TResult Function() unexpectedError,
  }) => serverError(message);

  @override
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverError,
    TResult? Function()? networkError,
    TResult? Function()? unauthorized,
    TResult? Function()? notFound,
    TResult? Function(Map<String, dynamic> errors)? validationError,
    TResult? Function()? unexpectedError,
  }) => serverError?.call(message);

  @override
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverError,
    TResult Function()? networkError,
    TResult Function()? unauthorized,
    TResult Function()? notFound,
    TResult Function(Map<String, dynamic> errors)? validationError,
    TResult Function()? unexpectedError,
    required TResult orElse(),
  }) => serverError != null ? serverError(message) : orElse();
}

class _$NetworkError implements NetworkError {
  const _$NetworkError();
  @override
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverError,
    required TResult Function() networkError,
    required TResult Function() unauthorized,
    required TResult Function() notFound,
    required TResult Function(Map<String, dynamic> errors) validationError,
    required TResult Function() unexpectedError,
  }) => networkError();
  @override TResult? whenOrNull<TResult extends Object?>({TResult? Function(String? message)? serverError, TResult? Function()? networkError, TResult? Function()? unauthorized, TResult? Function()? notFound, TResult? Function(Map<String, dynamic> errors)? validationError, TResult? Function()? unexpectedError}) => networkError?.call();
  @override TResult maybeWhen<TResult extends Object?>({TResult Function(String? message)? serverError, TResult Function()? networkError, TResult Function()? unauthorized, TResult Function()? notFound, TResult Function(Map<String, dynamic> errors)? validationError, TResult Function()? unexpectedError, required TResult orElse()}) => networkError != null ? networkError() : orElse();
}

class _$Unauthorized implements Unauthorized {
  const _$Unauthorized();
  @override TResult when<TResult extends Object?>({required TResult Function(String? message) serverError, required TResult Function() networkError, required TResult Function() unauthorized, required TResult Function() notFound, required TResult Function(Map<String, dynamic> errors) validationError, required TResult Function() unexpectedError}) => unauthorized();
  @override TResult? whenOrNull<TResult extends Object?>({TResult? Function(String? message)? serverError, TResult? Function()? networkError, TResult? Function()? unauthorized, TResult? Function()? notFound, TResult? Function(Map<String, dynamic> errors)? validationError, TResult? Function()? unexpectedError}) => unauthorized?.call();
  @override TResult maybeWhen<TResult extends Object?>({TResult Function(String? message)? serverError, TResult Function()? networkError, TResult Function()? unauthorized, TResult Function()? notFound, TResult Function(Map<String, dynamic> errors)? validationError, TResult Function()? unexpectedError, required TResult orElse()}) => unauthorized != null ? unauthorized() : orElse();
}

class _$NotFound implements NotFound {
  const _$NotFound();
  @override TResult when<TResult extends Object?>({required TResult Function(String? message) serverError, required TResult Function() networkError, required TResult Function() unauthorized, required TResult Function() notFound, required TResult Function(Map<String, dynamic> errors) validationError, required TResult Function() unexpectedError}) => notFound();
  @override TResult? whenOrNull<TResult extends Object?>({TResult? Function(String? message)? serverError, TResult? Function()? networkError, TResult? Function()? unauthorized, TResult? Function()? notFound, TResult? Function(Map<String, dynamic> errors)? validationError, TResult? Function()? unexpectedError}) => notFound?.call();
  @override TResult maybeWhen<TResult extends Object?>({TResult Function(String? message)? serverError, TResult Function()? networkError, TResult Function()? unauthorized, TResult Function()? notFound, TResult Function(Map<String, dynamic> errors)? validationError, TResult Function()? unexpectedError, required TResult orElse()}) => notFound != null ? notFound() : orElse();
}

class _$ValidationError implements ValidationError {
  const _$ValidationError({required this.errors});
  @override final Map<String, dynamic> errors;
  @override TResult when<TResult extends Object?>({required TResult Function(String? message) serverError, required TResult Function() networkError, required TResult Function() unauthorized, required TResult Function() notFound, required TResult Function(Map<String, dynamic> errors) validationError, required TResult Function() unexpectedError}) => validationError(errors);
  @override TResult? whenOrNull<TResult extends Object?>({TResult? Function(String? message)? serverError, TResult? Function()? networkError, TResult? Function()? unauthorized, TResult? Function()? notFound, TResult? Function(Map<String, dynamic> errors)? validationError, TResult? Function()? unexpectedError}) => validationError?.call(errors);
  @override TResult maybeWhen<TResult extends Object?>({TResult Function(String? message)? serverError, TResult Function()? networkError, TResult Function()? unauthorized, TResult Function()? notFound, TResult Function(Map<String, dynamic> errors)? validationError, TResult Function()? unexpectedError, required TResult orElse()}) => validationError != null ? validationError(errors) : orElse();
}

class _$UnexpectedError implements UnexpectedError {
  const _$UnexpectedError();
  @override TResult when<TResult extends Object?>({required TResult Function(String? message) serverError, required TResult Function() networkError, required TResult Function() unauthorized, required TResult Function() notFound, required TResult Function(Map<String, dynamic> errors) validationError, required TResult Function() unexpectedError}) => unexpectedError();
  @override TResult? whenOrNull<TResult extends Object?>({TResult? Function(String? message)? serverError, TResult? Function()? networkError, TResult? Function()? unauthorized, TResult? Function()? notFound, TResult? Function(Map<String, dynamic> errors)? validationError, TResult? Function()? unexpectedError}) => unexpectedError?.call();
  @override TResult maybeWhen<TResult extends Object?>({TResult Function(String? message)? serverError, TResult Function()? networkError, TResult Function()? unauthorized, TResult Function()? notFound, TResult Function(Map<String, dynamic> errors)? validationError, TResult Function()? unexpectedError, required TResult orElse()}) => unexpectedError != null ? unexpectedError() : orElse();
}

abstract class ServerError implements Failure { const factory ServerError({String? message}) = _$ServerError; String? get message; }
abstract class NetworkError implements Failure { const factory NetworkError() = _$NetworkError; }
abstract class Unauthorized implements Failure { const factory Unauthorized() = _$Unauthorized; }
abstract class NotFound implements Failure { const factory NotFound() = _$NotFound; }
abstract class ValidationError implements Failure { const factory ValidationError({required Map<String, dynamic> errors}) = _$ValidationError; Map<String, dynamic> get errors; }
abstract class UnexpectedError implements Failure { const factory UnexpectedError() = _$UnexpectedError; }
