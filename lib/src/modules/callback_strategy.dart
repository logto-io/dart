enum CallbackStrategyType {
  scheme,
  localServer
}

enum BrowserLaunchMode {
  platformDefault,
  external
}

abstract class CallbackStrategy {
  CallbackStrategyType get strategy;
  BrowserLaunchMode get launchMode;
}

class SchemeStrategy implements CallbackStrategy {
  late BrowserLaunchMode _launchMode;
  final CallbackStrategyType _strategy = CallbackStrategyType.scheme;

  SchemeStrategy({BrowserLaunchMode? launchMode}){
    _launchMode = launchMode ?? BrowserLaunchMode.platformDefault;
  }
  
  @override
  CallbackStrategyType get strategy => _strategy;
  
  @override
  BrowserLaunchMode get launchMode => _launchMode;

}

class LocalServerStrategy implements CallbackStrategy {
  late BrowserLaunchMode _launchMode;
  final CallbackStrategyType _strategy = CallbackStrategyType.localServer;
  final int _port;

  LocalServerStrategy(this._port,{BrowserLaunchMode? launchMode}){
    _launchMode = launchMode ?? BrowserLaunchMode.platformDefault;
  }

  @override
  CallbackStrategyType get strategy => _strategy;

  int get port => _port;
  
  @override
  BrowserLaunchMode get launchMode => _launchMode;
  
}