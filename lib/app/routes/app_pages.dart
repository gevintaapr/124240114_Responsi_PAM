import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/session_service.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/register_view.dart';
import '../modules/detail/detail_controller.dart';
import '../modules/detail/detail_view.dart';
import '../modules/favorite/favorite_controller.dart';
import '../modules/favorite/favorite_view.dart';
import '../modules/home/home_controller.dart';
import '../modules/home/home_view.dart';
import 'app_routes.dart';

/// Halaman utama hanya bisa dibuka setelah login.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<SessionService>().isLoggedIn
          ? null
          : const RouteSettings(name: Routes.login);
}

/// Pengguna yang sudah login tidak perlu melihat halaman login lagi.
class GuestGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<SessionService>().isLoggedIn
          ? const RouteSettings(name: Routes.home)
          : null;
}

class AppPages {
  static String get initial =>
      Get.find<SessionService>().isLoggedIn ? Routes.home : Routes.login;

  static final pages = <GetPage>[
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      middlewares: [GuestGuard()],
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      middlewares: [GuestGuard()],
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      middlewares: [AuthGuard()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => FavoriteController());
      }),
    ),
    GetPage(
      name: Routes.detail,
      page: () => const DetailView(),
      middlewares: [AuthGuard()],
      binding: BindingsBuilder(() => Get.lazyPut(() => DetailController())),
    ),
    GetPage(
      name: Routes.bookmark,
      page: () => const FavoriteView(),
      middlewares: [AuthGuard()],
      binding: BindingsBuilder(() => Get.lazyPut(() => FavoriteController())),
    ),
  ];
}
