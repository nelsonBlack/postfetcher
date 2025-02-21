import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart'
    if (dart.library.io) 'url_strategy_stub.dart';

void configureUrl() {
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
}
