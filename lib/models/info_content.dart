class InfoContent {
  final String title;
  final String content;
  final String contentType;
  
  const InfoContent({
    required this.title,
    required this.content,
    this.contentType = 'plain',
  });
  
  factory InfoContent.fromJson(Map<String, dynamic> json) {
    return InfoContent(
      title: json['title'] as String,
      content: json['content'] as String,
      contentType: json['content_type'] as String? ?? 'plain',
    );
  }
}
