import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/news.dart';
import '../../data/providers/api_provider.dart';
import '../../utils/snack.dart';

class HomeController extends GetxController {
  final ApiProvider _api = Get.find();

  /// Pilihan filter sumber berita (news site).
  static const newsSiteFilters = [
    'All',
    'NASA',
    'SpaceNews',
    'Spaceflight Now',
    'SpacePolicyOnline.com',
    'Space Scout',
    'Teslarati',
    'Arstechnica',
  ];

  final news = <News>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final query = ''.obs;

  /// Sumber berita yang dipilih ('All' = semua)
  final selectedSite = 'All'.obs;

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  int _page = 1;
  bool _hasNext = true;
  int _requestToken = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    // Debounce search input agar tidak membebani API saat mengetik
    debounce(query, (_) => fetch(), time: const Duration(milliseconds: 500));
    fetch();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  void selectSite(String site) {
    if (selectedSite.value == site) return;
    selectedSite.value = site;
    fetch();
  }

  void clearSearch() {
    searchController.clear();
    query.value = '';
  }

  /// Memuat halaman pertama berita sesuai pencarian dan filter news_site
  Future<void> fetch() async {
    final token = ++_requestToken;
    _page = 1;
    _hasNext = true;
    isLoading.value = true;
    isLoadingMore.value = false;
    errorMessage.value = null;

    try {
      final res = await _api.getNewsList(
        page: 1,
        limit: 10,
        search: query.value,
        newsSite: selectedSite.value == 'All' ? '' : selectedSite.value,
      );

      if (token != _requestToken) return;
      news.assignAll(res.items);
      _hasNext = res.hasNext;

      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    } on ApiException catch (e) {
      if (token != _requestToken) return;
      news.clear();
      errorMessage.value = e.message;
    } catch (_) {
      if (token != _requestToken) return;
      news.clear();
      errorMessage.value = 'Gagal memuat berita. Periksa koneksi Anda.';
    } finally {
      if (token == _requestToken) {
        isLoading.value = false;
      }
    }
  }

  /// Infinite scroll untuk memuat berita berikutnya
  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !_hasNext) return;

    final token = _requestToken;
    isLoadingMore.value = true;

    try {
      final nextPage = _page + 1;
      final res = await _api.getNewsList(
        page: nextPage,
        limit: 10,
        search: query.value,
        newsSite: selectedSite.value == 'All' ? '' : selectedSite.value,
      );

      if (token != _requestToken) return;
      _page = nextPage;
      _hasNext = res.hasNext;
      news.addAll(res.items);
    } on ApiException catch (e) {
      if (token == _requestToken) showErrorSnack(e.message);
    } catch (_) {
      if (token == _requestToken) showErrorSnack('Gagal memuat data lanjutan');
    } finally {
      if (token == _requestToken) {
        isLoadingMore.value = false;
      }
    }
  }
}
