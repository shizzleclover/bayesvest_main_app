import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/gradient_button.dart';
import '../controller/onboarding_controller.dart';
import '../model/financial_profile.dart';

class FinancialProfileScreen extends ConsumerStatefulWidget {
  const FinancialProfileScreen({super.key});

  @override
  ConsumerState<FinancialProfileScreen> createState() =>
      _FinancialProfileScreenState();
}

class _FinancialProfileScreenState
    extends ConsumerState<FinancialProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController();
  String? _selectedGoal;
  String? _selectedHorizon;
  bool _saving = false;

  static const _goals = [
    'Retirement',
    'Home Purchase',
    'Education',
    'Wealth Building',
    'Other',
  ];

  static const _horizons = [
    'Short-term (0-3 years)',
    'Medium-term (3-10 years)',
    'Long-term (10+ years)',
  ];

  @override
  void dispose() {
    _ageCtrl.dispose();
    _incomeCtrl.dispose();
    _savingsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final profile = FinancialProfile(
      age: int.parse(_ageCtrl.text.trim()),
      income: double.parse(_incomeCtrl.text.trim()),
      savings: double.parse(_savingsCtrl.text.trim()),
      goals: _selectedGoal,
      horizon: _selectedHorizon,
    );

    await ref.read(profileControllerProvider.notifier).saveProfile(profile);

    if (!mounted) return;
    setState(() => _saving = false);

    final state = ref.read(profileControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
      return;
    }

    context.go(AppRoutes.onboardingRisk);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // ── Progress ────────────────────────────────
                _StepIndicator(currentStep: 1, totalSteps: 2),

                SizedBox(height: 28.h),

                Text(
                  'Financial Profile',
                  style: GoogleFonts.manrope(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Help us understand your financial background',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Age ─────────────────────────────────────
                _FieldLabel('Age'),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'e.g. 28'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 18 || n > 120) return 'Enter a valid age';
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // ── Annual income ───────────────────────────
                _FieldLabel('Annual Income (\$)'),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _incomeCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'e.g. 75000'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) return 'Enter a number';
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // ── Savings ─────────────────────────────────
                _FieldLabel('Current Savings (\$)'),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _savingsCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(hintText: 'e.g. 15000'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) return 'Enter a number';
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // ── Goals dropdown ──────────────────────────
                _FieldLabel('Financial Goal'),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _selectedGoal,
                  decoration: const InputDecoration(hintText: 'Select a goal'),
                  items: _goals
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGoal = v),
                  validator: (v) => v == null ? 'Please select a goal' : null,
                ),

                SizedBox(height: 20.h),

                // ── Horizon dropdown ────────────────────────
                _FieldLabel('Investment Horizon'),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _selectedHorizon,
                  decoration:
                      const InputDecoration(hintText: 'Select a horizon'),
                  items: _horizons
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedHorizon = v),
                  validator: (v) => v == null ? 'Please select a horizon' : null,
                ),

                SizedBox(height: 36.h),

                GradientButton(
                  label: 'Continue',
                  isLoading: _saving,
                  onPressed: _submit,
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ─────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.totalSteps});
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i < currentStep;
        return Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8.w : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHigh,
              borderRadius: AppRadius.pill,
            ),
          ),
        );
      }),
    );
  }
}
