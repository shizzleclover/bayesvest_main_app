import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/dimensions.dart';

const _walkthroughKey = 'has_seen_walkthrough';

Future<bool> shouldShowWalkthrough() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_walkthroughKey) ?? false);
}

Future<void> markWalkthroughSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_walkthroughKey, true);
}

/// Full-screen modal walkthrough shown once after onboarding.
class WalkthroughOverlay extends StatefulWidget {
  const WalkthroughOverlay({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<WalkthroughOverlay> createState() => _WalkthroughOverlayState();
}

class _WalkthroughOverlayState extends State<WalkthroughOverlay> {
  int _page = 0;

  static const _steps = <_Step>[
    _Step(
      icon: Icons.shield_rounded,
      title: 'Your Risk Profile',
      body: 'We\u0027ve assessed your risk tolerance. This drives every recommendation we make for you.',
    ),
    _Step(
      icon: Icons.pie_chart_rounded,
      title: 'AI-Powered Portfolio',
      body: 'Tap "Generate My Portfolio" and our Bayesian engine will create a diversified allocation tailored to your profile.',
    ),
    _Step(
      icon: Icons.attach_money_rounded,
      title: 'See Real Amounts',
      body: 'Enter how much you want to invest on the Portfolio tab to see exactly how much goes into each asset.',
    ),
    _Step(
      icon: Icons.trending_up_rounded,
      title: 'Growth Projections',
      body: 'Use the Projections tool to visualize how your money could grow over 5, 10, or 30 years.',
    ),
    _Step(
      icon: Icons.flag_rounded,
      title: 'Set Savings Goals',
      body: 'Create goals like "Retirement" or "House Fund" and track your progress with visual rings.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final step = _steps[_page];

    return Material(
      color: cs.surface.withValues(alpha: 0.97),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              // Skip
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text('Skip',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp, color: cs.onSurfaceVariant)),
                ),
              ),

              const Spacer(),

              // Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(step.icon, size: 40.w, color: cs.primary),
              ),

              SizedBox(height: 32.h),

              Text(step.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),

              SizedBox(height: 16.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(step.body,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.sp,
                        color: cs.onSurfaceVariant,
                        height: 1.6)),
              ),

              const Spacer(),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _page ? 24.w : 8.w,
                    height: 8.w,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: i == _page ? cs.primary : cs.outlineVariant,
                      borderRadius: AppRadius.pill,
                    ),
                  );
                }),
              ),

              SizedBox(height: 32.h),

              // Next / Finish
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_page < _steps.length - 1) {
                      setState(() => _page++);
                    } else {
                      _finish();
                    }
                  },
                  child: Text(
                      _page < _steps.length - 1 ? 'Next' : 'Get Started'),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  void _finish() {
    markWalkthroughSeen();
    widget.onComplete();
  }
}

class _Step {
  final IconData icon;
  final String title;
  final String body;
  const _Step({required this.icon, required this.title, required this.body});
}
