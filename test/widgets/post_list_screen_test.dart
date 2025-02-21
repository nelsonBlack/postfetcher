import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutx/flutx.dart';
import 'package:postfetcher/domain/entities/post_entity.dart';
import 'package:postfetcher/presentation/controllers/post_controller.dart';
import 'package:postfetcher/presentation/views/post_detail_screen.dart';
import 'package:postfetcher/presentation/views/post_list_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

import 'package:postfetcher/presentation/widgets/post_list_item.dart';

class MockPostController extends Mock implements PostController {
  @override
  void Function() addListener(VoidCallback listener) => () {};
  @override
  void Function() removeListener(VoidCallback listener) => () {};
}

void main() {
  late MockPostController mockController;
  late Box postsBox;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    postsBox = await Hive.openBox('posts_cache');

    mockController = MockPostController();
    FxControllerStore.put(mockController);

    // Setup default mock behavior
    when(
      () => mockController.posts,
    ).thenReturn([PostEntity(id: 1, title: 'Test Post', body: 'Content')]);
    when(() => mockController.postState).thenReturn(PostState.success);
  });

  tearDown(() async {
    await postsBox.clear();
    await Hive.close();
    FxControllerStore.resetStore();
  });

  testWidgets('Shows loading indicator on initial load', (tester) async {
    when(() => mockController.postState).thenReturn(PostState.loading);

    await tester.pumpWidget(MaterialApp(home: PostListScreen()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('Displays error message on failed fetch', (tester) async {
    when(() => mockController.postState).thenReturn(PostState.error);
    when(() => mockController.errorMessage).thenReturn('Network error');

    await tester.pumpWidget(MaterialApp(home: PostListScreen()));
    await tester.pump();

    expect(find.text('Network error'), findsOneWidget);
  });

  testWidgets('Loads 10 posts per page', (tester) async {
    when(() => mockController.posts).thenReturn(
      List.generate(
        10,
        (i) => PostEntity(id: i, title: 'Post $i', body: 'Content $i'),
      ),
    );

    await tester.pumpWidget(MaterialApp(home: PostListScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(PostListItem), findsNWidgets(10));
  });

  testWidgets('Navigates to detail screen on post tap', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PostListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PostListItem).first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(PostDetailScreen), findsOneWidget);
  });
}
