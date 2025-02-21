import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:postfetcher/data/models/post_model.dart';
import 'package:postfetcher/data/datasources/post_remote_data_source.dart';
import 'package:postfetcher/domain/repositories/post_repository_impl.dart';
import 'package:postfetcher/domain/entities/post_entity.dart';
import 'package:postfetcher/core/errors/failures.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:postfetcher/core/constants/app_constants.dart';

class MockRemoteDataSource extends Mock implements PostRemoteDataSource {}

class MockConnectivity extends Mock implements Connectivity {}

class MockBox extends Mock implements Box<PostModel> {}

class MockDio extends Mock implements Dio {}

void main() {
  late PostRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockConnectivity mockConnectivity;
  late MockBox mockBox;
  late MockDio mockDio;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(ConnectivityResult.none);

    mockBox = MockBox();
    mockRemoteDataSource = MockRemoteDataSource();
    mockConnectivity = MockConnectivity();
    mockDio = MockDio();

    when(() => mockRemoteDataSource.dio).thenReturn(mockDio);

    // Mock the check method to avoid MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'check') {
              return 'wifi';
            }
            return null;
          },
        );

    repository = PostRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
      box: mockBox,
    );

    when(() => mockBox.clear()).thenAnswer((_) async => Future.value());
    when(
      () => mockBox.put(any(), any()),
    ).thenAnswer((_) async => Future.value());
  });

  group('getPosts', () {
    test('Returns cached posts when offline', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.none);
      when(
        () => mockBox.values,
      ).thenReturn([PostModel(id: 1, title: 'Cached Post', body: 'Content')]);

      final result = await repository.getPosts(1);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (posts) => expect(posts.first.title, 'Cached Post'),
      );
      verify(() => mockConnectivity.checkConnectivity()).called(1);
      verifyNever(() => mockRemoteDataSource.getPosts(1));
    });

    test('Returns remote posts when online and caches them (page 1)', () async {
      final mockPostModels = [
        PostModel(id: 1, title: 'Post 1', body: 'Body 1'),
        PostModel(id: 2, title: 'Post 2', body: 'Body 2'),
      ];
      final mockPostEntities =
          mockPostModels.map((e) => PostEntity.fromMap(e.toMap())).toList();

      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.mobile);
      when(
        () => mockRemoteDataSource.getPosts(1),
      ).thenAnswer((_) async => mockPostModels.map((e) => e.toMap()).toList());

      when(() => mockBox.clear()).thenAnswer((_) async => Future.value());

      final result = await repository.getPosts(1);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (posts) => expect(posts, mockPostEntities),
      );
      verify(() => mockConnectivity.checkConnectivity()).called(1);
      verify(() => mockRemoteDataSource.getPosts(1)).called(1);
      verify(() => mockBox.clear()).called(1);
    });

    test(
      'Returns remote posts when online and caches them (page > 1)',
      () async {
        final mockPostModels = [
          PostModel(id: 1, title: 'Post 1', body: 'Body 1'),
          PostModel(id: 2, title: 'Post 2', body: 'Body 2'),
        ];
        final mockPostEntities =
            mockPostModels.map((e) => PostEntity.fromMap(e.toMap())).toList();

        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.mobile);
        when(
          () => mockRemoteDataSource.getPosts(2),
        ).thenAnswer((_) async => mockPostModels as List<Map<String, dynamic>>);

        final result = await repository.getPosts(2);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (posts) => expect(posts, mockPostEntities),
        );
        verify(() => mockConnectivity.checkConnectivity()).called(1);
        verify(() => mockRemoteDataSource.getPosts(2)).called(1);
        verifyNever(() => mockBox.clear());
      },
    );

    test('Returns Failure when remote data source fails', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.mobile);
      when(
        () => mockRemoteDataSource.getPosts(1),
      ).thenThrow(ServerFailure('Failed to fetch posts'));

      final result = await repository.getPosts(1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (posts) => fail('Should return failure'),
      );
    });
  });

  group('getCachedPosts', () {
    test('Returns cached posts when available', () async {
      when(
        () => mockBox.values,
      ).thenReturn([PostModel(id: 1, title: 'Cached Post', body: 'Content')]);

      final result = await repository.getCachedPosts();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (posts) => expect(posts.first.title, 'Cached Post'),
      );
    });

    test('Returns CacheFailure when no cached posts available', () async {
      when(() => mockBox.values).thenReturn([]);

      final result = await repository.getCachedPosts();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (posts) => fail('Should return failure'),
      );
    });
  });

  group('getPost', () {
    test('Returns PostEntity on success', () async {
      final mockPostModel = PostModel(id: 1, title: 'Post 1', body: 'Body 1');
      when(
        () => mockRemoteDataSource.getPost(1),
      ).thenAnswer((_) async => mockPostModel.toMap());

      final result = await repository.getPost(1);

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('should not be left'),
        (r) => expect(r, PostEntity.fromMap(mockPostModel.toMap())),
      );
    });

    test('Returns Failure on error', () async {
      when(
        () => mockRemoteDataSource.getPost(1),
      ).thenThrow(ServerFailure('Failed to fetch post'));

      final result = await repository.getPost(1);

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('should not be right'),
      );
    });
  });
}
