import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postfetcher/data/datasources/post_remote_data_source.dart';
import 'package:postfetcher/domain/repositories/post_repository_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MockRemoteDataSource extends Mock implements PostRemoteDataSource {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late PostRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockConnectivity = MockConnectivity();
    repository = PostRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
    );
  });

  test('Returns cached posts when offline', () async {
    // Mock connectivity check to return false
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => ConnectivityResult.none);

    final result = await repository.getPosts(1);
    expect(result.isRight(), true);
    verifyNever(
      () => mockRemoteDataSource.getPosts(any()),
    ); // Verify no network call
  });
}
