import 'package:get/get.dart';

import '../../data/models/news.dart';
import '../../data/providers/api_provider.dart';

class DetailController extends GetxController {
  final ApiProvider _api = Get.find();

  /// Data awal dari list (langsung tampil), lalu diperbarui dari
  /// endpoint /character/{id}.
  final news = Rxn<News>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final int _id;

  @override
  void onInit() {
    super.onInit();
    // Data yang dikirim dari Home lewat Get.toNamed(Routes.detail, arguments: character).
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
    isLoading.value = true;
    errorMessage.value = null;
    try {
      // GET /articles/{id} untuk data paling baru.
      news.value = await _api.getNews(_id);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
