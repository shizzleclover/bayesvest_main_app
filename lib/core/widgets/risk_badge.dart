import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/dimensions.dart';

/// Color-coded risk level badge.
///
/// Accepts [band] (0-4) for the colour/label and [rawScore] (0-100)
/// for the numeric display. Falls back to showing band if rawScore
/// is not provided.
class RiskBadge extends StatelessWidget {
  const RiskBadge({
    super.key,
    required this.band,
    this.rawScore,
  });

  final double band;
  final int? rawScore;

  static const _levels = [
    ('Conservative', Color(0xFF16A34A)),
    ('Moderate', Color(0xFF2563EB)),
    ('Balanced', Color(0xFFF59E0B)),
    ('Growth', Color(0xFFF97316)),
    ('Aggressive', Color(0xFFDC2626)),
  ];

  (String, Color) get _level {
    final idx = band.round().clamp(0, _levels.length - 1);
    return _levels[idx];
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _level;
    final scoreText = rawScore != null ? '$rawScore/100' : '${band.toStringAsFixed(0)}/4';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$label \u2022 $scoreText',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
