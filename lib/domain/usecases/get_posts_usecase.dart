import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<PostEntity>>> execute({required int page}) async {
    return await repository.getPosts(page);
  }
}
