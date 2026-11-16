import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// import '../models/character.dart';
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

  // Alamat dasar API. Semua endpoint ditambahkan di belakangnya.
  static const baseUrl = 'https://api.spaceflightnewsapi.net/v4/articles';
  // Jika server tidak menjawab dalam 15 detik, request dianggap gagal.
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// GET /character, /character?status=alive|dead|unknown, dan ?name= (bonus).
  Future<PagedResult<News>> getNewss({
    int page = 1,
    String title = '',
    String newsSite = '',
  }) async {
    // Parameter yang kosong tidak dikirim, jadi tanpa filter hasilnya
    // GET /character?page=1, dan dengan filter GET /character?page=1&status=alive
    final json = await _get('/articles', {
      'page': '$page',
      if (newsSite.isNotEmpty) 'news_site': newsSite,
      if (title.trim().isNotEmpty) 'title': title.trim(),
    });
    return _paged(json, News.fromJson);
  }

  /// GET /character/{id}
  Future<News> getNews(int id) async {
    final json = await _get('/news/$id');
    if (json == null) throw const ApiException('Berita tidak ditemukan');
    return News.fromJson(json);
  }


  PagedResult<T> _paged<T>(
    Map<String, dynamic>? json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // API mengembalikan 404 kalau filter/pencarian tidak punya hasil.
    if (json == null) return PagedResult<T>([], false);
    // Bentuk respons API: { "info": { "next": url|null, ... }, "results": [ ... ] }
    // 'results' diubah satu per satu menjadi objek lewat fromJson.
    final results = (json['results'] as List? ?? [])
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final info = json['info'];
    // Jika info.next bernilai null, berarti ini halaman terakhir.
    return PagedResult<T>(results, info is Map && info['next'] != null);
  }

  /// Mengembalikan `null` untuk 404, melempar [ApiException] untuk error lain.
  Future<Map<String, dynamic>?> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    // Menyusun URL lengkap, misalnya:
    // https://rickandmortyapi.com/api/character?page=1&status=dead
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);
    try {
      // Kirim request GET dan tunggu jawabannya (maksimal 15 detik).
      final response = await _client.get(uri).timeout(_timeout);
      // 404 = data tidak ditemukan (misalnya hasil pencarian kosong),
      // bukan error koneksi, jadi dikembalikan sebagai 'tidak ada data'.
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw ApiException(
          'Server bermasalah (kode ${response.statusCode}). Coba lagi nanti.',
        );
      }
      // 200 OK: ubah teks JSON menjadi Map Dart.
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Koneksi terlalu lama. Periksa internet kamu.');
    } on FormatException {
      throw const ApiException('Data dari server tidak valid.');
    } catch (_) {
      // Error lain, biasanya karena tidak ada koneksi internet.
      throw const ApiException(
        'Gagal terhubung ke server. Periksa koneksi internet kamu.',
      );
    }
  }
}
