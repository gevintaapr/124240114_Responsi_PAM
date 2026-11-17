import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/news.dart';
import '../../modules/favorite/favorite_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/snack.dart';
import '../../widgets/news_widgets.dart';
import '../../widgets/glass.dart';
import '../../widgets/state_views.dart';
import 'detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  Future<void> _openFullArticle(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null) {
      try {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) {
          showErrorSnack('Tidak dapat membuka browser untuk URL ini');
        }
      } catch (_) {
        showErrorSnack('Gagal membuka artikel di browser');
      }
    } else {
      showErrorSnack('URL artikel tidak valid');
    }
  }

  PreferredSizeWidget _appBar(News? news) {
    final favoriteController = Get.find<FavoriteController>();
    return AppBar(
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
          const Text('Detail Berita', style: TextStyle(fontSize: 18)),
        ],
      ),
      actions: [
        if (news != null)
          Obx(() {
            final isFav = favoriteController.isFavorite(news.id);
            return GlassIconButton(
              icon: isFav
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              iconColor: isFav ? AppColors.pink : AppColors.text,
              tooltip: isFav ? 'Hapus Bookmark' : 'Tambah Bookmark',
              onPressed: () => favoriteController.toggle(news),
            );
          }),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final news = controller.news.value;
      final error = controller.errorMessage.value;

      if (news == null) {
        return GlassScaffold(
          appBar: _appBar(null),
          body: error != null
              ? MessageView(
                  icon: Icons.wifi_off_rounded,
                  title: 'Gagal memuat detail',
                  message: error,
                  onRetry: controller.fetch,
                )
              : const LoadingView(label: 'Memuat detail berita...'),
        );
      }

      return GlassScaffold(
        appBar: _appBar(news),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gambar Berita
                    _Photo(news: news),

                    if (controller.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    const SizedBox(height: 18),

                    // Judul Berita
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sumber Berita, Tanggal Publikasi, Penulis
                    GlassContainer(
                      radius: AppRadius.md,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _MetaRow(
                            icon: Icons.newspaper_rounded,
                            label: 'Sumber Berita',
                            value: news.newsSite,
                            valueColor: AppColors.purple,
                          ),
                          const Divider(height: 18, thickness: 0.8),
                          _MetaRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Tanggal Publikasi',
                            value: news.formattedDate,
                          ),
                          const Divider(height: 18, thickness: 0.8),
                          _MetaRow(
                            icon: Icons.person_rounded,
                            label: 'Penulis',
                            value: news.authors,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ringkasan Berita
                    const _SectionTitle('Ringkasan Berita'),
                    const SizedBox(height: 10),
                    GlassContainer(
                      radius: AppRadius.md,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        news.summary.trim().isEmpty
                            ? 'Tidak ada ringkasan yang tersedia untuk artikel ini.'
                            : news.summary,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Read Full Article
                    GradientButton(
                      label: 'Read Full Article',
                      onPressed: () => _openFullArticle(news.url),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Tambah/Hapus Bookmark
                    _BookmarkActionButton(news: news),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.news});

  final News news;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AppColors.glass,
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: NewsImage(url: news.imageUrl, radius: AppRadius.lg),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _BookmarkActionButton extends StatelessWidget {
  const _BookmarkActionButton({required this.news});

  final News news;

  @override
  Widget build(BuildContext context) {
    final favorites = Get.find<FavoriteController>();
    return Obx(() {
      final isFav = favorites.isFavorite(news.id);
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(
            color: isFav ? AppColors.pink : AppColors.glassBorder,
            width: 1.5,
          ),
          backgroundColor: isFav
              ? AppColors.pink.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm + 4),
          ),
        ),
        onPressed: () => favorites.toggle(news),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isFav ? AppColors.pink : AppColors.text,
            ),
            const SizedBox(width: 8),
            Text(
              isFav ? 'Hapus dari Bookmark' : 'Tambah ke Bookmark',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isFav ? AppColors.pink : AppColors.text,
              ),
            ),
          ],
        ),
      );
    });
  }
}
