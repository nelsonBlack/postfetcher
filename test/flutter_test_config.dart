import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() {
    // Configure Hive for tests
    Hive.init('./test/hive_testing');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  await testMain();
}
