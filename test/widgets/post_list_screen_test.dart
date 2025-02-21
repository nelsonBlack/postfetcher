import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutx/flutx.dart';
import 'package:postfetcher/data/models/post_model.dart';
import 'package:postfetcher/domain/entities/post_entity.dart';
import 'package:postfetcher/presentation/controllers/post_controller.dart';
import 'package:postfetcher/presentation/views/post_list_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:postfetcher/presentation/widgets/post_list_item.dart';

class MockPostController extends Mock implements PostController {
  @override
  String getTag() => 'post_controller';

  @override
  bool save = true;

  @override
  Future<void> fetchInitialPosts() async {} // Keep this as async

  @override
  void Function() addListener(VoidCallback listener) => () {};
  @override
  void Function() removeListener(VoidCallback listener) => () {};

  @override
  List<PostEntity> get posts => [
    PostEntity(id: 1, title: 'Test Post', body: 'Content'),
  ];

  @override
  PostState get postState => PostState.success;

  @override
  String get errorMessage => ''; // Change to non-nullable String
}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockPostController mockController;
  late Box<PostModel> postsBox;
  late Directory tempDir;
  late GoRouter mockRouter;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp();

    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(PostModelAdapter().typeId)) {
      Hive.registerAdapter(PostModelAdapter());
    }

    postsBox = await Hive.openBox<PostModel>('posts_cache');

    mockController = MockPostController();
    mockRouter = MockGoRouter();
    FxControllerStore.put(mockController);

    // Setup default mock behavior (simplified)
    when(
      () => mockController.fetchInitialPosts(),
    ).thenAnswer((_) async => Future.value());
    when(() => mockRouter.go(any())).thenReturn(null);
  });

  tearDown(() async {
    await postsBox.close();
    await Hive.close();
    await tempDir.delete(recursive: true);
    FxControllerStore.resetStore();
  });

  testWidgets('Displays error message on failed fetch', (tester) async {
    when(() => mockController.postState).thenReturn(PostState.error);
    when(() => mockController.errorMessage).thenReturn('Network error');

    await tester.pumpWidget(
      MaterialApp(
        home: InheritedGoRouter(goRouter: mockRouter, child: PostListScreen()),
      ),
    );
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

    await tester.pumpWidget(
      MaterialApp(
        home: InheritedGoRouter(goRouter: mockRouter, child: PostListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PostListItem), findsNWidgets(10));
  });

  testWidgets('Navigates to detail screen on post tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InheritedGoRouter(goRouter: mockRouter, child: PostListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PostListItem).first);
    await tester.pumpAndSettle();

    verify(() => mockRouter.go(any())).called(1);
  });
}
