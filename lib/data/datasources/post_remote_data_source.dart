import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

abstract class PostRemoteDataSource {
  Dio get dio;
  Future<List<Map<String, dynamic>>> getPosts(int page);
  Future<Map<String, dynamic>> getPost(int id);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  @override
  final Dio dio;

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getPosts(int page) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/posts',
        queryParameters: {'_page': page, '_limit': AppConstants.postsPerPage},
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Unknown Dio error');
    } catch (e) {
      throw ServerFailure('Failed to fetch posts: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPost(int id) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/posts/$id');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Unknown Dio error');
    }
  }
}
