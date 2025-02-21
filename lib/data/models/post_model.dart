import 'package:hive/hive.dart';

part 'post_model.g.dart';

@HiveType(typeId: 0)
class PostModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String body;

  PostModel({required this.id, required this.title, required this.body});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'body': body};
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(id: map['id'], title: map['title'], body: map['body']);
  }
}
