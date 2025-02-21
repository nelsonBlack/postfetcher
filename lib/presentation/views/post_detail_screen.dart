import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:postfetcher/core/errors/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import 'package:go_router/go_router.dart';

class PostDetailScreen extends StatelessWidget {
  final PostEntity post;
  final PostRepository repository;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('home');
            }
          },
        ),
        title: const Text('Post Details'),
      ),
      body: Container(
        color: theme.colorScheme.surface,
        padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              post.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Other Posts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Either<Failure, List<PostEntity>>>(
                future: repository.getPosts(1),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return snapshot.data!.fold(
                    (failure) => Text(
                      'Failed to load other posts: ${failure.message}',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    (posts) => ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final otherPost = posts[index];
                        if (otherPost.id == post.id)
                          return const SizedBox.shrink();

                        return ListTile(
                          title: Text(
                            otherPost.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          onTap: () => context.navigateToPostDetail(otherPost),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* void _navigateToDetail(BuildContext context, PostEntity post) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder:
          (context, animation, secondaryAnimation) =>
              PostDetailScreen(post: post),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  );
} */

extension PostDetailNavigation on BuildContext {
  void navigateToPostDetail(PostEntity post) {
    pushNamed('post', pathParameters: {'id': post.id.toString()}, extra: post);
  }
}
