import 'package:flutx/flutx.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../domain/usecases/get_posts_usecase.dart';
import '../../domain/entities/post_entity.dart';
import '../../core/errors/failures.dart';
import '../../data/models/post_model.dart';

enum PostState { initial, loading, success, error }

class PostController extends FxController {
  final GetPostsUseCase _getPostsUseCase;
  List<PostEntity> posts = [];
  int page = 1;
  bool hasReachedMax = false;
  PostState postState = PostState.initial;
  String errorMessage = '';

  PostController(this._getPostsUseCase);

  @override
  void initState() {
    super.initState();
    fetchInitialPosts();
  }

  Future<void> fetchInitialPosts() async {
    page = 1;
    _updateState(PostState.loading);
    try {
      final result = await _getPostsUseCase.execute(page: page);
      result.fold(
        (failure) => _handleFailure(failure),
        (newPosts) => _handleNewPosts(newPosts),
      );
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> fetchMorePosts() async {
    if (postState == PostState.loading || hasReachedMax) return;
    _updateState(PostState.loading);
    try {
      final result = await _getPostsUseCase.execute(page: page + 1);
      result.fold(
        (failure) => _handleFailure(failure),
        (newPosts) => _handleNewPosts(newPosts),
      );
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> refreshPosts() async {
    page = 1;
    hasReachedMax = false;
    return fetchInitialPosts();
  }

  void _handleNewPosts(List<PostEntity> newPosts) {
    hasReachedMax = newPosts.isEmpty;
    page += 1;
    posts = page == 2 ? newPosts : [...posts, ...newPosts];
    _updateState(PostState.success);
    _cachePosts();
  }

  void _handleFailure(Failure failure) {
    errorMessage = failure.message;
    _updateState(PostState.error);
    _loadCachedPosts();
  }

  void _handleError(String message) {
    errorMessage = message;
    _updateState(PostState.error);
    _loadCachedPosts();
  }

  void _updateState(PostState newState) {
    postState = newState;
    debugPrint('Updating state to: $newState');
    update();
  }

  @override
  void update() {
    debugPrint('Controller update called');
    super.update();
  }

  Future<void> _cachePosts() async {
    final box = await Hive.openBox<PostModel>('posts_cache');
    await box.clear();
    final models =
        posts
            .map((e) => PostModel(id: e.id, title: e.title, body: e.body))
            .toList();
    await box.addAll(models);
  }

  Future<void> _loadCachedPosts() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      final box = await Hive.openBox<PostModel>('posts_cache');
      posts =
          box.values
              .map(
                (model) => PostEntity(
                  id: model.id,
                  title: model.title,
                  body: model.body,
                ),
              )
              .toList();
      update();
    }
  }

  @override
  String getTag() => 'post_controller';
}
