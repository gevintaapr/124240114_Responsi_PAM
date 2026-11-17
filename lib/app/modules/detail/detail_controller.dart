import 'package:get/get.dart';

import '../../data/models/news.dart';
import '../../data/providers/api_provider.dart';

class DetailController extends GetxController {
  final ApiProvider _api = Get.find();

  final news = Rxn<News>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final int _id;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is News) {
      news.value = args;
      _id = args.id;
    } else {
      _id = args is int ? args : 0;
    }
    fetch();
  }

  Future<void> fetch() async {
    if (_id <= 0) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      news.value = await _api.getNewsDetail(_id);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Gagal memuat rincian berita.';
    } finally {
      isLoading.value = false;
    }
  }
}
