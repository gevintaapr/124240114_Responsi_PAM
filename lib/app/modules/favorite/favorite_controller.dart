import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../data/models/character.dart';
import '../../data/models/news.dart';
import '../../data/services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/snack.dart';

/// Satu-satunya sumber data favorit untuk seluruh aplikasi.
///
/// Home, Detail, dan Favorite Screen sama-sama membaca [favorites] lewat Obx,
/// sehingga perubahan di satu halaman langsung terlihat di halaman lain.
class FavoriteController extends GetxController {
  final SessionService _session = Get.find();

  final favorites = <News>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    // Muat ulang favorit setiap kali akun yang login berganti.
    ever(_session.currentUser, (_) => _load());
  }

  void _load() => favorites.assignAll(_session.readFavorites());

  bool isFavorite(int id) => favorites.any((c) => c.id == id);

  /// Menambah atau menghapus favorit, lalu menampilkan Snackbar.
  void toggle(News news) {
    if (isFavorite(news.id)) {
      favorites.removeWhere((c) => c.id == news.id);
      showSnack(
        '${news.title} dihapus dari favorit',
        icon: Icons.heart_broken_outlined,
        iconColor: AppColors.unknown,
      );
    } else {
      favorites.add(news);
      showSnack(
        '${news.title} ditambahkan ke favorit',
        icon: Icons.favorite,
        iconColor: AppColors.favorite,
      );
    }
    _session.writeFavorites(favorites);
  }

  /// Dipakai oleh swipe di Favorite Screen. Snackbar punya aksi "Batal".
  void removeBySwipe(News news) {
    final index = favorites.indexWhere((c) => c.id == news.id);
    if (index < 0) return;
    favorites.removeAt(index);
    _session.writeFavorites(favorites);
    showSnack(
      '${news.title} berhasil dihapus dari favorit',
      icon: Icons.delete_outline,
      iconColor: AppColors.dead,
      actionLabel: 'BATAL',
      onAction: () {
        if (isFavorite(news.id)) return;
        favorites.insert(index.clamp(0, favorites.length), news);
        _session.writeFavorites(favorites);
      },
    );
  }
}
