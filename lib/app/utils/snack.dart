import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Key global supaya Snackbar bisa dipanggil dari controller (tanpa context).
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showSnack(
  String message, {
  IconData icon = Icons.info_outline,
  Color iconColor = AppColors.yellow,
  Color? backgroundColor,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: backgroundColor != null ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: backgroundColor != null ? Colors.white : null,
                onPressed: onAction ?? () {},
              ),
      ),
    );
}

/// Menampilkan snackbar hijau saat menambahkan bookmark (sesuai ketentuan soal)
void showSuccessSnack(String message) {
  showSnack(
    message,
    icon: Icons.check_circle_outline_rounded,
    iconColor: Colors.white,
    backgroundColor: const Color(0xFF16A34A), // Hijau
  );
}

/// Menampilkan snackbar merah saat menghapus bookmark (sesuai ketentuan soal)
void showBookmarkRemovedSnack(
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  showSnack(
    message,
    icon: Icons.delete_outline_rounded,
    iconColor: Colors.white,
    backgroundColor: const Color(0xFFDC2626), // Merah
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

void showErrorSnack(String message) => showSnack(
      message,
      icon: Icons.error_outline,
      iconColor: Colors.white,
      backgroundColor: const Color(0xFFDC2626),
    );
