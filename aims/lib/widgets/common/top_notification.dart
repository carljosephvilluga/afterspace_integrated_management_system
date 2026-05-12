// Purpose: Shows reusable floating notification messages across the app.
import 'dart:async';

import 'package:flutter/material.dart';

OverlayEntry? _activeTopNotification;
Timer? _activeTopNotificationTimer;

void showTopNotification(
  BuildContext context, {
  required String message,
  String? title,
  bool isError = false,
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    return;
  }

  _activeTopNotificationTimer?.cancel();
  _activeTopNotification?.remove();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final color = isError ? const Color(0xFFC95656) : const Color(0xFF80AEC1);
      final background = isError
          ? const Color(0xFFFFF4F4)
          : const Color(0xF7FFFFFF);

      return Positioned(
        top: 16,
        left: 16,
        right: 16,
        child: SafeArea(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -10 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.32)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon ??
                              (isError
                                  ? Icons.error_outline_rounded
                                  : Icons.notifications_active_outlined),
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title != null) ...[
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Color(0xFF23323A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              message,
                              style: const TextStyle(
                                color: Color(0xFF23323A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          _activeTopNotificationTimer?.cancel();
                          _activeTopNotification?.remove();
                          _activeTopNotification = null;
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF6F7E87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  _activeTopNotification = entry;
  overlay.insert(entry);
  _activeTopNotificationTimer = Timer(duration, () {
    if (_activeTopNotification == entry) {
      entry.remove();
      _activeTopNotification = null;
    }
  });
}
