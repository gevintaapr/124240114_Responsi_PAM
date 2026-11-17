import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news.dart';

/// Error yang pesannya aman ditampilkan langsung ke pengguna.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Satu halaman hasil dari endpoint yang memakai pagination.
class PagedResult<T> {
  final List<T> items;
  final bool hasNext;
  const PagedResult(this.items, this.hasNext);
}

class ApiProvider {
  ApiProvider([http.Client? client]) : _client = client ?? http.Client();

  // Alamat dasar Spaceflight News API v4
  static const baseUrl = 'https://api.spaceflightnewsapi.net/v4';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// GET /articles/ dengan query limit, offset, search, news_site
  Future<PagedResult<News>> getNewsList({
    int page = 1,
    int limit = 10,
    String search = '',
    String newsSite = '',
  }) async {
    final offset = (page - 1) * limit;
    final query = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    if (search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (newsSite.trim().isNotEmpty && newsSite.toLowerCase() != 'all') {
      query['news_site'] = newsSite.trim();
    }

    final json = await _get('/articles/', query);
    return _paged(json, News.fromJson);
  }

  /// GET /articles/{id}/
  Future<News> getNewsDetail(int id) async {
    final json = await _get('/articles/$id/');
    if (json == null) throw const ApiException('Berita tidak ditemukan.');
    return News.fromJson(json);
  }

  PagedResult<T> _paged<T>(
    Map<String, dynamic>? json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json == null) return PagedResult<T>([], false);
    final results = (json['results'] as List? ?? [])
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final next = json['next'];
    return PagedResult<T>(results, next != null);
  }

  /// Mengembalikan `null` untuk 404, melempar [ApiException] untuk error lain.
  Future<Map<String, dynamic>?> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
    try {
      final response = await _client.get(
        uri,
        headers: const {'User-Agent': 'SpaceNewsExplorer/1.0'},
      ).timeout(_timeout);

      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw ApiException(
          'Server bermasalah (kode ${response.statusCode}). Coba lagi nanti.',
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Koneksi timeout. Periksa koneksi internet Anda.');
    } catch (_) {
      throw const ApiException('Tidak dapat terhubung ke server.');
    }
  }
}
