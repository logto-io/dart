enum CallbackStrategyType {
  scheme,
  localServer
}

abstract class CallbackStrategy {
  final CallbackStrategyType _strategy = CallbackStrategyType.scheme;

  CallbackStrategyType get strategy => _strategy;
}

class SchemeStrategy implements CallbackStrategy {
  @override
  late CallbackStrategyType _strategy;

  SchemeStrategy(){
    _strategy = CallbackStrategyType.scheme;
  }
  
  @override
  CallbackStrategyType get strategy => _strategy;

}

class LocalServerStrategy implements CallbackStrategy {
  @override
  late CallbackStrategyType _strategy;
  final int _port;

  LocalServerStrategy(this._port) {
    _strategy  = CallbackStrategyType.localServer;
  }

  @override
  CallbackStrategyType get strategy => _strategy;

  int get port => _port;
  
}