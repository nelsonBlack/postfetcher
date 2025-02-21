import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutx/state_management/builder.dart';
import 'package:flutx/state_management/controller_store.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postfetcher/core/config/router_config.dart';
import 'package:postfetcher/data/models/post_model.dart';
import 'package:postfetcher/domain/entities/post_entity.dart';
import 'package:postfetcher/domain/usecases/get_posts_usecase.dart';
import 'package:postfetcher/presentation/controllers/app_controller.dart';
import 'package:postfetcher/presentation/controllers/post_controller.dart';
import 'package:postfetcher/presentation/views/post_detail_screen.dart';
import 'package:postfetcher/presentation/views/post_list_screen.dart';
import 'package:postfetcher/presentation/views/splash_screen.dart';
import 'package:postfetcher/presentation/widgets/post_list_item.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postfetcher/domain/repositories/post_repository.dart';
import 'package:postfetcher/data/datasources/post_remote_data_source.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Mock classes
class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}

class MockDio extends Mock implements Dio {}

class MockPostRepository extends Mock implements PostRepository {}

class MockConnectivity extends Mock implements Connectivity {}

class MockGetPostsUseCase extends Mock implements GetPostsUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    late Box appSettingsBox;
    late Box<PostModel> postsBox;
    late MockGetPostsUseCase mockUseCase;

    setUp(() async {
      final tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PostModelAdapter());
      }

      // Open boxes
      appSettingsBox = await Hive.openBox('app_settings');
      postsBox = await Hive.openBox<PostModel>('posts_cache');

      // Setup mocks
      mockUseCase = MockGetPostsUseCase();
      when(() => mockUseCase.execute(page: any(named: 'page'))).thenAnswer(
        (_) async => Right([
          PostEntity(id: 1, title: 'Test Post', body: 'Test Content'),
          PostEntity(id: 2, title: 'Another Post', body: 'More Content'),
        ]),
      );

      // Register controllers
      FxControllerStore.put(PostController(mockUseCase));
    });

    tearDown(() async {
      await appSettingsBox.clear();
      await postsBox.clear();
      await Hive.close();
      FxControllerStore.resetStore();
    });

    testWidgets('Full app flow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FxBuilder<AppController>(
            controller: FxControllerStore.putOrFind(
              AppController(appSettingsBox),
            ),
            builder: (controller) => PostListScreen(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for data
      await tester.pumpAndSettle();
      expect(find.byType(PostListItem), findsWidgets);

      // Navigate to detail
      await tester.tap(find.byType(PostListItem).first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(PostDetailScreen), findsOneWidget);
    });
  });
}
