import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/news_widgets.dart';
import '../../widgets/glass.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  void _confirmLogout() {
    Get.dialog(
      GlassDialog(
        icon: Icons.logout_rounded,
        title: 'Logout',
        message: 'Yakin ingin keluar dari akun ini?',
        actions: [
          OutlinedButton(
            onPressed: Get.back,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.glassBorder, width: 1.5),
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm + 4),
              ),
            ),
            child: const Text('Batal'),
          ),
          GradientButton(
            label: 'Logout',
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
          ),
        ],
      ),
      barrierColor: AppColors.text.withValues(alpha: 0.25),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();

    return GlassScaffold(
      appBar: AppBar(
        titleSpacing: 20,
        // Pada title AppBar, tampilkan username pengguna yang sedang login
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SpaceNews Explorer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                'Hai, ${session.currentUser.value ?? 'Pengguna'} 👋',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Button pada bagian kanan AppBar yang mengarah ke halaman Bookmark
          GlassIconButton(
            icon: Icons.bookmark_rounded,
            tooltip: 'Halaman Bookmark',
            onPressed: () => Get.toNamed(Routes.bookmark),
          ),
          const SizedBox(width: 8),
          // Button logout
          GlassIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Kotak Pencarian
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Obx(
              () => TextField(
                controller: controller.searchController,
                onChanged: (v) => controller.query.value = v,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Cari berita eksplorasi antariksa...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: controller.query.value.isEmpty
                      ? null
                      : IconButton(
                          onPressed: controller.clearSearch,
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
              ),
            ),
          ),

          // Fitur Filter Berita berdasarkan Sumber Berita (news site)
          SizedBox(
            height: 44,
            child: Obx(
              () => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: HomeController.newsSiteFilters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final site = HomeController.newsSiteFilters[index];
                  final isSelected = controller.selectedSite.value == site;
                  return Center(
                    child: _FilterChip(
                      label: site,
                      selected: isSelected,
                      onTap: () => controller.selectSite(site),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Konten Berita / Loading Indicator
          Expanded(child: Obx(_buildBody)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Tampilkan loading indicator ketika data sedang dimuat
    if (controller.isLoading.value) {
      return const LoadingView(label: 'Memuat berita antariksa...');
    }

    final error = controller.errorMessage.value;
    if (error != null) {
      return MessageView(
        icon: Icons.wifi_off_rounded,
        title: 'Gagal memuat berita',
        message: error,
        onRetry: controller.fetch,
      );
    }

    if (controller.news.isEmpty) {
      return const MessageView(
        icon: Icons.newspaper_rounded,
        gradient: AppGradients.warm,
        title: 'Berita tidak ditemukan',
        message: 'Coba kata kunci atau filter sumber berita yang lain.',
      );
    }

    final showFooter = controller.isLoadingMore.value;

    return RefreshIndicator(
      onRefresh: controller.fetch,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 210,
              ),
              itemCount: controller.news.length,
              itemBuilder: (_, index) {
                final item = controller.news[index];
                return NewsGridCard(key: ValueKey(item.id), news: item);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: showFooter
                ? const LoadMoreIndicator()
                : const SizedBox.shrink(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(999);
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: selected ? AppGradients.primary : null,
          color: selected ? null : AppColors.glassStrong,
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.glassBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.pink.withValues(alpha: 0.28)
                  : AppColors.shadow,
              blurRadius: selected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: selected ? Colors.white : AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
