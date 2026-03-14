import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/dimensions.dart';

/// Color-coded risk level badge.
///
/// Maps a numeric risk score (0-4) to a label and colour.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.riskScore});

  final double riskScore;

  static const _levels = [
    ('Conservative', Color(0xFF16A34A)),
    ('Moderate', Color(0xFF2563EB)),
    ('Balanced', Color(0xFFF59E0B)),
    ('Growth', Color(0xFFF97316)),
    ('Aggressive', Color(0xFFDC2626)),
  ];

  (String, Color) get _level {
    final idx = riskScore.round().clamp(0, _levels.length - 1);
    return _levels[idx];
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _level;

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
            '$label \u2022 ${riskScore.toStringAsFixed(0)}/4',
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
