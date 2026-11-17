import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/news.dart';
import '../modules/favorite/favorite_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

/// Foto berita dengan placeholder saat memuat / gagal.
class NewsImage extends StatelessWidget {
  const NewsImage({
    super.key,
    required this.url,
    this.radius = AppRadius.sm,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String url;
  final double radius;
  final double? width;
  final double? height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(IconData icon) => Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEDE4FF), Color(0xFFFCE4F1)],
        ),
      ),
      child: Icon(icon, color: AppColors.purple.withValues(alpha: 0.5)),
    );

    if (url.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: placeholder(Icons.newspaper_rounded),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        alignment: alignment,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : placeholder(Icons.image_outlined),
        errorBuilder: (_, _, _) => placeholder(Icons.broken_image_outlined),
      ),
    );
  }
}

/// Label sumber berita (news site).
class NewsSiteBadge extends StatelessWidget {
  const NewsSiteBadge({super.key, required this.newsSite});

  final String newsSite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        newsSite,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.purple,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Tombol bookmark bulat berlatar kaca; ikonnya berubah warna mengikuti status bookmark.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({super.key, required this.news, this.size = 36});

  final News news;
  final double size;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoriteController>();
    return Obx(() {
      final isFav = favorites.isFavorite(news.id);
      return Tooltip(
        message: isFav ? 'Hapus bookmark' : 'Tambah bookmark',
        child: Material(
          color: Colors.white.withValues(alpha: 0.88),
          shape: const CircleBorder(),
          elevation: 1,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => favorites.toggle(news),
            child: SizedBox(
              width: size,
              height: size,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  key: ValueKey(isFav),
                  size: size * 0.56,
                  color: isFav ? AppColors.pink : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Kompatibilitas mundur
typedef FavoriteButton = BookmarkButton;

/// Kartu berita untuk grid / list di Home.
/// Menampilkan: gambar, judul berita, sumber berita (news site), tanggal publikasi.
class NewsGridCard extends StatelessWidget {
  const NewsGridCard({super.key, required this.news});

  final News news;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(8),
      onTap: () => Get.toNamed(Routes.detail, arguments: news),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: NewsImage(
                    url: news.imageUrl,
                    radius: AppRadius.sm,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: BookmarkButton(news: news, size: 32),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: NewsSiteBadge(newsSite: news.newsSite),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        news.formattedDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu berita horizontal untuk Bookmark Screen (cocok untuk swipe).
class NewsTile extends StatelessWidget {
  const NewsTile({super.key, required this.news});

  final News news;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: AppRadius.md,
      padding: const EdgeInsets.all(10),
      onTap: () => Get.toNamed(Routes.detail, arguments: news),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NewsImage(url: news.imageUrl, width: 72, height: 72),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                NewsSiteBadge(newsSite: news.newsSite),
                const SizedBox(height: 4),
                Text(
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  news.formattedDate,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          BookmarkButton(news: news, size: 36),
        ],
      ),
    );
  }
}
