import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../widgets/news_widgets.dart';
import '../../widgets/glass.dart';
import '../../widgets/state_views.dart';
import 'favorite_controller.dart';

class FavoriteView extends GetView<FavoriteController> {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            GlassIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Kembali',
              onPressed: Get.back,
            ),
            const SizedBox(width: 14),
            const Text(
              'Bookmark Berita',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.favorites.isEmpty) {
          return const MessageView(
            icon: Icons.bookmark_border_rounded,
            title: 'Belum ada berita di-bookmark',
            message: 'Tekan ikon bookmark pada berita untuk menyimpannya ke daftar ini.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          itemCount: controller.favorites.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.swipe_left_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${controller.favorites.length} berita tersimpan · geser ke kiri untuk menghapus',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final news = controller.favorites[index - 1];

            // Dismissible membuat kartu bisa digeser (swipe) untuk dihapus sesuai soal
            return Dismissible(
              key: ValueKey('bookmark_${news.id}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => controller.removeBySwipe(news),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x00F0506E), AppColors.dead],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.delete_rounded, color: Colors.white),
                  ],
                ),
              ),
              child: NewsTile(news: news),
            );
          },
        );
      }),
    );
  }
}
