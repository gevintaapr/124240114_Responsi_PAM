import 'package:get/get.dart';

import '../../data/models/news.dart';
import '../../data/services/session_service.dart';
import '../../utils/snack.dart';

/// Satu-satunya sumber data bookmark untuk seluruh aplikasi.
///
/// Home, Detail, dan Bookmark Screen sama-sama membaca [favorites] lewat Obx,
/// sehingga perubahan di satu halaman langsung terlihat di halaman lain.
class FavoriteController extends GetxController {
  final SessionService _session = Get.find();

  final favorites = <News>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    // Muat ulang bookmark setiap kali akun yang login berganti.
    ever(_session.currentUser, (_) => _load());
  }

  void _load() => favorites.assignAll(_session.readFavorites());

  bool isFavorite(int id) => favorites.any((c) => c.id == id);

  /// Menambah atau menghapus bookmark, lalu menampilkan Snackbar hijau/merah.
  void toggle(News news) {
    if (isFavorite(news.id)) {
      favorites.removeWhere((c) => c.id == news.id);
      _session.writeFavorites(favorites);
      showBookmarkRemovedSnack('${news.title} dihapus dari bookmark');
    } else {
      favorites.add(news);
      _session.writeFavorites(favorites);
      showSuccessSnack('${news.title} ditambahkan ke bookmark');
    }
  }

  /// Dipakai oleh swipe di Bookmark Screen. Snackbar punya aksi "Batal".
  void removeBySwipe(News news) {
    final index = favorites.indexWhere((c) => c.id == news.id);
    if (index < 0) return;
    favorites.removeAt(index);
    _session.writeFavorites(favorites);
    showBookmarkRemovedSnack(
      '${news.title} berhasil dihapus dari bookmark',
      actionLabel: 'BATAL',
      onAction: () {
        if (isFavorite(news.id)) return;
        favorites.insert(index.clamp(0, favorites.length), news);
        _session.writeFavorites(favorites);
      },
    );
  }
}
