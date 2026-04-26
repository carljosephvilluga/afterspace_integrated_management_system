import 'dart:math' as math;

import 'package:flutter/foundation.dart';

class SpacePricing {
  const SpacePricing({
    required this.boardRoomHourlyRate,
    required this.ordinarySpaceHourlyRate,
  });

  final double boardRoomHourlyRate;
  final double ordinarySpaceHourlyRate;
}

class SpacePricingStore {
  SpacePricingStore._();

  static final ValueNotifier<SpacePricing> pricingNotifier =
      ValueNotifier<SpacePricing>(
    const SpacePricing(
      boardRoomHourlyRate: 350,
      ordinarySpaceHourlyRate: 120,
    ),
  );

  static SpacePricing get current => pricingNotifier.value;

  static void update({
    required double boardRoomHourlyRate,
    required double ordinarySpaceHourlyRate,
  }) {
    pricingNotifier.value = SpacePricing(
      boardRoomHourlyRate: boardRoomHourlyRate,
      ordinarySpaceHourlyRate: ordinarySpaceHourlyRate,
    );
  }

  static double hourlyRateForSpace(String spaceUsed) {
    final normalized = spaceUsed.toLowerCase();
    if (normalized.contains('board')) {
      return current.boardRoomHourlyRate;
    }
    return current.ordinarySpaceHourlyRate;
  }

  static double totalForVisit({
    required String spaceUsed,
    required DateTime timeIn,
    DateTime? timeOut,
  }) {
    final end = timeOut ?? DateTime.now();
    final minutes = math.max(1, end.difference(timeIn).inMinutes);
    return hourlyRateForSpace(spaceUsed) * (minutes / 60);
  }

  static String formatCurrency(double amount) {
    return 'PHP ${amount.toStringAsFixed(2)}';
  }
}
