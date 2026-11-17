/// Model berita untuk SpaceNews Explorer
class News {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String authors;

  const News({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.authors,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '-',
      url: json['url']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ??
          (json['imageUrl']?.toString() ?? ''),
      newsSite: json['news_site']?.toString() ??
          (json['newsSite']?.toString() ?? '-'),
      summary: json['summary']?.toString() ?? '',
      publishedAt: json['published_at']?.toString() ??
          (json['publishedAt']?.toString() ?? ''),
      authors: _parseAuthors(json['authors']),
    );
  }

  static String _parseAuthors(dynamic raw) {
    if (raw == null) return 'Tidak diketahui';
    if (raw is List) {
      if (raw.isEmpty) return 'Tidak diketahui';
      final names = raw
          .map((item) {
            if (item is Map && item['name'] != null) {
              return item['name'].toString();
            } else if (item is String) {
              return item;
            }
            return item.toString();
          })
          .where((s) => s.trim().isNotEmpty)
          .toList();
      return names.isNotEmpty ? names.join(', ') : 'Tidak diketahui';
    }
    if (raw is String) {
      return raw.trim().isNotEmpty ? raw : 'Tidak diketahui';
    }
    return raw.toString();
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final monthName = months[dt.month - 1];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $monthName ${dt.year}, $hour:$minute';
    } catch (_) {
      return publishedAt;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'image_url': imageUrl,
    'news_site': newsSite,
    'summary': summary,
    'published_at': publishedAt,
    'authors': authors,
  };
}
