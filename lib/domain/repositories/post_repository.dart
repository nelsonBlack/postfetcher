import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts(int page);
  Future<Either<Failure, List<PostEntity>>> getCachedPosts();
  Future<Either<Failure, PostEntity>> getPost(int id);
}
