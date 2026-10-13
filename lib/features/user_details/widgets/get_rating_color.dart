import 'dart:ui';

import 'package:flutter/material.dart';

Color getRatingColor(int rating, int maxRating) {
  if (rating >= 4000) return const Color(0xFF000000);
  if (rating >= 3000) return const Color(0xFFFF0000);
  if (rating >= 2600) return const Color(0xFFFF0000);
  if (rating >= 2400) return const Color(0xFFFF0000);
  if (rating >= 2300) return const Color(0xFFFF8C00);
  if (rating >= 2100) return const Color(0xFFFF8C00);
  if (rating >= 1900) return const Color(0xFFAA00AA);
  if (rating >= 1600) return const Color(0xFF0000FF);
  if (rating >= 1400) return const Color(0xFF03A89E);
  if (rating >= 1200) return const Color(0xFF008000);
  if (rating == 0 && maxRating == 0) return const Color(0xFF000000);

  return const Color(0xFF808080);
}
