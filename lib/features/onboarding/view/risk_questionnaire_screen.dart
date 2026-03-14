import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/onboarding_controller.dart';

/// Question data — matches the backend answer keys and the options
/// defined in `screen_map.md`.
class _Question {
  final String key;
  final String text;
  final List<String> options;
  const _Question(this.key, this.text, this.options);
}

const _questions = <_Question>[
  _Question('age_bracket', 'What is your current age bracket?',
      ['Under 30', '30 - 45', '46 - 60', '60+']),
  _Question('horizon', 'When do you expect to need this capital?', [
    'Long-Term (10+ years)',
    'Medium-Term (3-10 years)',
    'Short-Term (0-3 years)',
  ]),
  _Question(
      'risk_tolerance', 'If your portfolio dropped 20%, what would you do?',
      ['Buy More', 'Wait it out', 'Panic Sell']),
  _Question('experience', 'How would you rate your investment experience?', [
    'Advanced (Derivatives/Crypto)',
    'Intermediate (Stocks/ETFs)',
    'Beginner (No experience)',
  ]),
  _Question('income_stability', 'How stable is your income?',
      ['Highly Stable', 'Variable / Freelance', 'Unstable / Unemployed']),
  _Question('liquidity_needs', 'Do you need to withdraw investments soon?',
      ['None', 'Moderate', 'High (May need cash soon)']),
  _Question('primary_goal', 'What is the main goal of this portfolio?', [
    'Aggressive Growth',
    'Balanced Wealth Accumulation',
    'Capital Preservation',
  ]),
  _Question('debt_to_income', 'How would you describe your debt levels?',
      ['Low (Comfortable)', 'Moderate (Manageable)', 'High (Strained)']),
  _Question('dependents', 'How many dependents do you support?',
      ['None', '1-2', '3+']),
  _Question(
      'reaction_to_volatility',
      'How do you handle severe portfolio fluctuations?',
      [
        'Excited by opportunity',
        'Slightly concerned but stay the course',
        'Anxious and want to sell',
      ]),
];

class RiskQuestionnaireScreen extends ConsumerStatefulWidget {
  const RiskQuestionnaireScreen({super.key, this.isRetake = false});

  final bool isRetake;

  @override
  ConsumerState<RiskQuestionnaireScreen> createState() =>
      _RiskQuestionnaireScreenState();
}

class _RiskQuestionnaireScreenState
    extends ConsumerState<RiskQuestionnaireScreen> {
  int _current = 0;
  final Map<String, String> _answers = {};
  bool _submitting = false;

  void _select(String option) {
    final q = _questions[_current];
    setState(() => _answers[q.key] = option);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_current < _questions.length - 1) {
        setState(() => _current++);
      }
    });
  }

  void _back() {
    if (_current > 0) setState(() => _current--);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final result =
        await ref.read(riskControllerProvider.notifier).submitAnswers(_answers);

    if (!mounted) return;
    setState(() => _submitting = false);

    // Show computed score briefly.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ScoreDialog(
        score: result.computedRiskScore,
        rawScore: result.rawScore,
        riskLevel: result.riskLevel,
      ),
    );

    if (!mounted) return;
    if (widget.isRetake) {
      ref.invalidate(riskControllerProvider);
      Navigator.of(context).pop();
    } else {
      ref.read(authControllerProvider.notifier).markOnboardingComplete();
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;
    final allAnswered = _answers.length == _questions.length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // ── Top bar ───────────────────────────────────
              Row(
                children: [
                  if (_current > 0)
                    GestureDetector(
                      onTap: _back,
                      child: Icon(Icons.arrow_back_rounded,
                          color: colorScheme.onSurface, size: 24.w),
                    )
                  else
                    SizedBox(width: 24.w),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.pill,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4.h,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        color: colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    '${_current + 1}/${_questions.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // ── Question ──────────────────────────────────
              Text(
                q.text,
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  height: 1.35,
                ),
              ),

              SizedBox(height: 32.h),

              // ── Option cards ──────────────────────────────
              ...q.options.map((opt) {
                final selected = _answers[q.key] == opt;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: GestureDetector(
                    onTap: () => _select(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 18.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? colorScheme.primaryContainer
                                .withValues(alpha: 0.10)
                            : colorScheme.surfaceContainerLowest,
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: selected
                              ? colorScheme.primaryContainer
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.sp,
                                fontWeight:
                                    selected ? FontWeight.w600 : FontWeight.w400,
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle_rounded,
                                color: colorScheme.primary, size: 22.w),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // ── Submit (last question only) ───────────────
              if (_current == _questions.length - 1 && allAnswered)
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: SizedBox(
                    height: 52.h,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ]),
                        borderRadius: AppRadius.button,
                      ),
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button),
                        ),
                        child: _submitting
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colorScheme.onPrimary),
                              )
                            : Text(
                                'Submit',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score Dialog ─────────────────────────────────────────────

class _ScoreDialog extends StatelessWidget {
  const _ScoreDialog({
    required this.score,
    this.rawScore,
    this.riskLevel,
  });

  final double score;
  final int? rawScore;
  final String? riskLevel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) Navigator.of(context).pop();
    });

    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: colorScheme.primary, size: 56.w),
            SizedBox(height: 16.h),
            Text(
              'Risk Score',
              style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              rawScore != null ? '$rawScore' : score.toStringAsFixed(1),
              style: GoogleFonts.manrope(
                fontSize: 48.sp,
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              rawScore != null ? 'out of 100' : 'out of 4',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (riskLevel != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  riskLevel!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
