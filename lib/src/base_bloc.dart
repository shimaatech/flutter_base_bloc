
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Bloc base state
/// All states must inherit from [BlocState]
abstract class BlocState implements Equatable {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class StateLoading extends BlocState {
  final double progress;

  StateLoading([this.progress]);

  @override
  List<Object> get props => [progress];
}

class StateInitial extends BlocState {}


class StateError extends BlocState {
  final String message;
  final dynamic exception;
  final StackTrace stackTrace;

  StateError(this.message, [this.exception, this.stackTrace]);

  @override
  List<Object> get props => [message, exception];

  @override
  String toString() {
    return "Error: $message";
  }
}

/// Bloc base event
/// All events must inherit from [BlocEvent]
abstract class BlocEvent implements Equatable {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}


abstract class BaseBloc extends Bloc<BlocEvent, BlocState> {

  @override
  BlocState get initialState => StateInitial();

}


class _EventInitialize extends BlocEvent {}

class StateInitialized extends BlocState {}

abstract class InitializableBloc extends BaseBloc {

  bool _initialized = false;
  bool get initialized => _initialized;

  InitializableBloc() {
    add(_EventInitialize());
  }

  @override
  Stream<BlocState> mapEventToState(BlocEvent event) async* {
    if (event is _EventInitialize) {
      yield* _initialize();
    } else if (initialized) {
      yield* eventToState(event);
    }
  }

  @mustCallSuper
  Stream<BlocState> _initialize() async* {
    try {
      await initialize();
      _initialized = true;
      yield StateInitialized();
    } catch(e, stackTrace) {
      yield StateError('Failed to initialize bloc', e, stackTrace);
    }
  }

  Stream<BlocState> eventToState(BlocEvent event);

  Future<void> initialize();

}