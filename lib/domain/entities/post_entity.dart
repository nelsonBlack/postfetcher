class PostEntity {
  final int id;
  final String title;
  final String body;

  PostEntity({required this.id, required this.title, required this.body});

  // Add factory method
  factory PostEntity.fromMap(Map<String, dynamic> map) => PostEntity(
    id: map['id'] as int,
    title: map['title'] as String,
    body: map['body'] as String,
  );
}
