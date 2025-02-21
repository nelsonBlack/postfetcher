import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:postfetcher/data/models/post_model.dart';
import 'package:postfetcher/data/datasources/post_remote_data_source.dart';
import 'package:postfetcher/domain/repositories/post_repository_impl.dart';
import 'dart:io';

class MockRemoteDataSource extends Mock implements PostRemoteDataSource {}

class MockConnectivity extends Mock implements Connectivity {}

class MockBox extends Mock implements Box<PostModel> {}

void main() {
  late PostRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockConnectivity mockConnectivity;
  late MockBox mockBox;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Use mocks instead of real Hive
    mockBox = MockBox();
    mockRemoteDataSource = MockRemoteDataSource();
    mockConnectivity = MockConnectivity();

    repository = PostRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
      box: mockBox, // Inject mock box
    );

    // Setup default mock responses
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => ConnectivityResult.none);

    when(
      () => mockBox.values,
    ).thenReturn([PostModel(id: 1, title: 'Cached Post', body: 'Content')]);
  });

  test('Returns cached posts when offline', () async {
    // Act
    final result = await repository.getPosts(1);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (posts) => expect(posts.first.title, 'Cached Post'),
    );
    verify(() => mockConnectivity.checkConnectivity()).called(1);
    verifyZeroInteractions(mockRemoteDataSource);
  });
}
