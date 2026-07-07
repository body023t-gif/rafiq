import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  static const bool _isDebug = !bool.fromEnvironment('dart.vm.product');

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (_isDebug) {
      dev.log('BlocCreated: ${bloc.runtimeType}');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (_isDebug) {
      dev.log('BlocEvent: ${bloc.runtimeType}, Event: $event');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (_isDebug) {
      dev.log('BlocChange: ${bloc.runtimeType}, CurrentState: ${change.currentState}, NextState: ${change.nextState}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (_isDebug) {
      dev.log('BlocTransition: ${bloc.runtimeType}, Event: ${transition.event}, CurrentState: ${transition.currentState}, NextState: ${transition.nextState}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (_isDebug) {
      dev.log('BlocError: ${bloc.runtimeType}, Error: $error', stackTrace: stackTrace);
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (_isDebug) {
      dev.log('BlocClosed: ${bloc.runtimeType}');
    }
  }
}
