/// Model karakter Rick and Morty.
///
/// Bentuk JSON hasil [toJson] sengaja dibuat sama dengan bentuk JSON dari API,
/// sehingga [News.fromJson] bisa dipakai untuk data dari API maupun data
/// favorit yang disimpan di Shared Preferences.
class  News {
  final int id;
  final String title;
  final String image;
  final String newsSite;
  final String publishedAt;

  const News({
    required this.id,
    required this.title,
    required this.image,
    required this.newsSite,
    required this.publishedAt
  });

  factory News.fromJson(Map<String, dynamic> json) {
    String nested(dynamic value) {
      if (value is Map && value['title'] != null)
        return value['title'].toString();
      return 'unknown';
    }

    return News(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '-',
      image: json['image_url']?.toString() ?? '',
      newsSite: json['news_site']?.toString() ?? '-',
      publishedAt: json['published_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image_url': image,
    'news_site': newsSite,
    'published_at': publishedAt,
  };
}
