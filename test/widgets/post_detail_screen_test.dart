import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:postfetcher/domain/entities/post_entity.dart';
import 'package:postfetcher/presentation/views/post_detail_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:postfetcher/core/errors/failures.dart';
import 'package:postfetcher/domain/repositories/post_repository.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('PostDetailScreen Tests', () {
    late MockPostRepository mockRepo;
    late GoRouter mockRouter;

    setUp(() {
      mockRepo = MockPostRepository();
      mockRouter = MockGoRouter();

      // Setup mock repository
      when(() => mockRepo.getPosts(any())).thenAnswer((_) async => Right([]));

      // Setup mock router
      when(() => mockRouter.canPop()).thenReturn(true);
      when(() => mockRouter.go(any())).thenReturn(null);
    });

    testWidgets('Displays post details correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PostDetailScreen(
            post: PostEntity(id: 1, title: 'Test', body: 'Content'),
            repository: mockRepo,
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('Shows related posts section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PostDetailScreen(
            post: PostEntity(id: 1, title: 'Test', body: 'Content'),
            repository: mockRepo,
          ),
        ),
      );
      expect(find.text('Other Posts'), findsOneWidget);
    });

    testWidgets('Navigates to other posts on tap', (tester) async {
      // Setup mock repository to return some posts
      when(() => mockRepo.getPosts(any())).thenAnswer(
        (_) async => Right([
          PostEntity(id: 2, title: 'Related Post', body: 'Related Content'),
        ]),
      );

      // Add mock for pushNamed
      when(
        () => mockRouter.pushNamed(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockRouter,
            child: PostDetailScreen(
              post: PostEntity(id: 1, title: 'Test', body: 'Content'),
              repository: mockRepo,
            ),
          ),
        ),
      );

      // Wait for the related posts to load
      await tester.pump();
      await tester.pumpAndSettle();

      // Now we can tap the ListTile
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Verify pushNamed was called instead of go
      verify(
        () => mockRouter.pushNamed(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).called(1);
    });
  });
}
