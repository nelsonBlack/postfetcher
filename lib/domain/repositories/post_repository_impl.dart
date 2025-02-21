import 'dart:io';
import 'dart:html' if (dart.library.io) 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:postfetcher/core/errors/failures.dart';
import 'package:postfetcher/data/datasources/post_remote_data_source.dart';
import 'package:postfetcher/domain/entities/post_entity.dart';
import 'package:postfetcher/domain/repositories/post_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../../data/models/post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:postfetcher/core/constants/app_constants.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  final Box<PostModel> box;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivity,
    Box<PostModel>? box,
  }) : box = box ?? Hive.box('posts_cache');

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts(int page) async {
    try {
      final connectivityResult =
          kIsWeb
              ? await checkWebConnectivity()
              : await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return getCachedPosts();
      }

      final response = await remoteDataSource.getPosts(page);
      final posts = response.map((e) => PostEntity.fromMap(e)).toList();

      // Cache the posts
      await _cachePosts(posts, page);

      return Right(posts);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getCachedPosts() async {
    try {
      final posts =
          box.values
              .map(
                (post) =>
                    PostEntity(id: post.id, title: post.title, body: post.body),
              )
              .toList();

      if (posts.isEmpty) {
        return Left(CacheFailure('No cached posts available'));
      }
      return Right(posts);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached posts'));
    }
  }

  Future<void> _cachePosts(List<PostEntity> posts, int page) async {
    if (page == 1) await box.clear();
    for (var post in posts) {
      await box.put(
        post.id,
        PostModel(id: post.id, title: post.title, body: post.body),
      );
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPost(int id) async {
    try {
      final response = await remoteDataSource.getPost(id);
      return Right(PostEntity.fromMap(response));
    } on Failure catch (e) {
      return Left(e);
    }
  }

  Future<ConnectivityResult> checkWebConnectivity() async {
    if (kIsWeb) {
      try {
        final response = await remoteDataSource.dio.get(
          '${AppConstants.baseUrl}/posts/1',
        );
        return response.statusCode == 200
            ? ConnectivityResult.wifi
            : ConnectivityResult.none;
      } catch (_) {
        return ConnectivityResult.none;
      }
    } else {
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty
            ? ConnectivityResult.wifi
            : ConnectivityResult.none;
      } catch (_) {
        return ConnectivityResult.none;
      }
    }
  }
}
