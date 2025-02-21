import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:postfetcher/core/errors/failures.dart';
import '../../data/datasources/post_remote_data_source.dart';
import '../../domain/repositories/post_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../presentation/views/post_detail_screen.dart';
import '../../presentation/views/post_list_screen.dart';
import '../../presentation/views/settings_screen.dart';
import '../../presentation/views/splash_screen.dart';
import '../../presentation/controllers/post_controller.dart';
import 'package:flutx/flutx.dart';
import 'package:dartz/dartz.dart';
import '../../presentation/widgets/scaffold_with_navigation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final _repository = PostRepositoryImpl(
  remoteDataSource: PostRemoteDataSourceImpl(dio: Dio()),
  connectivity: Connectivity(),
);

final GoRouter routerConfig = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder:
              (context, state) => MaterialPage(
                key: state.pageKey,
                child: const PostListScreen(),
              ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder:
              (context, state) => MaterialPage(
                key: state.pageKey,
                child: const SettingsScreen(),
              ),
        ),
      ],
    ),
    GoRoute(
      path: '/post/:id',
      name: 'post',
      pageBuilder: (context, state) {
        final postId = int.parse(state.pathParameters['id']!);
        final post = state.extra as PostEntity?;

        return MaterialPage(
          key: state.pageKey,
          child: PostDetailScreen(
            post: post ?? PostEntity(id: postId, title: 'Loading...', body: ''),
            repository: _repository,
          ),
        );
      },
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.error}')),
      ),
);
