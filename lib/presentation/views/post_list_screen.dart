import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:dio/dio.dart';
import 'package:postfetcher/data/datasources/post_remote_data_source.dart';
import 'package:postfetcher/domain/usecases/get_posts_usecase.dart';
import 'package:hive/hive.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/post_entity.dart';
import '../controllers/post_controller.dart';
import '../widgets/error_view.dart';
import '../widgets/post_list_item.dart';
import '../widgets/loading_indicator.dart';
import '../../domain/repositories/post_repository_impl.dart';
import '../views/post_detail_screen.dart';
import 'post_detail_screen.dart';
import '../controllers/app_controller.dart';
import '../../core/utils/responsive_layout.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final _scrollController = ScrollController();
  late PostController _postController;
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _postController = FxControllerStore.putOrFind(
      PostController(
        GetPostsUseCase(
          PostRepositoryImpl(
            remoteDataSource: PostRemoteDataSourceImpl(dio: Dio()),
            connectivity: Connectivity(),
          ),
        ),
      ),
    );
    _scrollController.addListener(_onScroll);
    _postController.fetchInitialPosts();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _postController.fetchMorePosts();
    }
  }

  void _handleNavigation(int index, BuildContext context) {
    // Handle navigation logic based on the selected index
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FxBuilder<PostController>(
      controller: _postController,
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: controller.refreshPosts,
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          child:
              ResponsiveLayout.isDesktop(context)
                  ? _buildDesktopLayout(controller, theme)
                  : _buildMobileLayout(controller, theme),
        );
      },
    );
  }

  Widget _buildDesktopLayout(PostController controller, ThemeData theme) {
    return _buildContent(controller, theme);
  }

  Widget _buildMobileLayout(PostController controller, ThemeData theme) {
    return _buildContent(controller, theme);
  }

  Widget _buildContent(PostController controller, ThemeData theme) {
    if (controller.postState == PostState.initial) return const SizedBox();
    if (controller.postState == PostState.error) {
      return ErrorView(
        message: controller.errorMessage,
        onRetry: controller.fetchInitialPosts,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            ResponsiveLayout.isMobile(context)
                ? 1
                : constraints.maxWidth ~/ 400;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          padding: const EdgeInsets.all(16),
          controller: _scrollController,
          itemCount: controller.posts.length + 1,
          itemBuilder: (context, index) {
            if (index < controller.posts.length) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  // Fade transition
                  return FadeTransition(opacity: animation, child: child);
                },
                child: PostListItem(
                  key: ValueKey(controller.posts[index].id),
                  post: controller.posts[index],
                  onTap:
                      () => _navigateToDetail(context, controller.posts[index]),
                ),
              );
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  controller.hasReachedMax
                      ? _buildEndOfList(theme)
                      : const LoadingIndicator(),
            );
          },
        );
      },
    );
  }

  Widget _buildEndOfList(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Padding(
            padding: EdgeInsets.only(top: 20 * value),
            child: child,
          ),
        );
      },
      child: ListTile(
        title: Text(
          'No more posts',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, PostEntity post) {
    context.goNamed(
      'post',
      pathParameters: {'id': post.id.toString()},
      extra: post,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
