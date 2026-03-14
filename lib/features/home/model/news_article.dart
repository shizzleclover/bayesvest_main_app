class NewsArticle {
  final String title;
  final String summary;
  final String source;
  final String url;
  final int publishedAt;
  final String imageUrl;

  const NewsArticle({
    required this.title,
    required this.summary,
    required this.source,
    required this.url,
    required this.publishedAt,
    required this.imageUrl,
  });

  String get timeAgo {
    final diff = DateTime.now().millisecondsSinceEpoch ~/ 1000 - publishedAt;
    if (diff < 3600) return '${(diff / 60).floor()}m ago';
    if (diff < 86400) return '${(diff / 3600).floor()}h ago';
    return '${(diff / 86400).floor()}d ago';
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        source: json['source'] as String? ?? '',
        url: json['url'] as String? ?? '',
        publishedAt: (json['published_at'] as num?)?.toInt() ?? 0,
        imageUrl: json['image_url'] as String? ?? '',
      );
}
