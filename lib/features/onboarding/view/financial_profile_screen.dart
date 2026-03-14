import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/currency_toggle.dart';
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

  static const _goalItems = [
    AppDropdownItem(value: 'Retirement', label: 'Retirement', icon: Icons.beach_access_rounded),
    AppDropdownItem(value: 'Home Purchase', label: 'Home Purchase', icon: Icons.home_rounded),
    AppDropdownItem(value: 'Education', label: 'Education', icon: Icons.school_rounded),
    AppDropdownItem(value: 'Wealth Building', label: 'Wealth Building', icon: Icons.trending_up_rounded),
    AppDropdownItem(value: 'Other', label: 'Other', icon: Icons.more_horiz_rounded),
  ];

  static const _horizonItems = [
    AppDropdownItem(
      value: 'Short-term (0-3 years)',
      label: 'Short-term',
      subtitle: '0 \u2013 3 years',
      icon: Icons.flash_on_rounded,
    ),
    AppDropdownItem(
      value: 'Medium-term (3-10 years)',
      label: 'Medium-term',
      subtitle: '3 \u2013 10 years',
      icon: Icons.timeline_rounded,
    ),
    AppDropdownItem(
      value: 'Long-term (10+ years)',
      label: 'Long-term',
      subtitle: '10+ years',
      icon: Icons.landscape_rounded,
    ),
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
    final currency = ref.watch(currencyProvider);

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

                SizedBox(height: 24.h),

                // ── Currency toggle ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Currency',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const CurrencyToggle(),
                  ],
                ),

                SizedBox(height: 24.h),

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
                _FieldLabel('Annual Income (${currency.symbol})'),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _incomeCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'e.g. 75000',
                    prefixText: '${currency.symbol} ',
                    prefixStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) return 'Enter a number';
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // ── Savings ─────────────────────────────────
                _FieldLabel('Current Savings (${currency.symbol})'),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _savingsCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'e.g. 15000',
                    prefixText: '${currency.symbol} ',
                    prefixStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) return 'Enter a number';
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // ── Goals ───────────────────────────────────
                _FieldLabel('Financial Goal'),
                SizedBox(height: 8.h),
                AppDropdown<String>(
                  items: _goalItems,
                  value: _selectedGoal,
                  label: 'Financial Goal',
                  hintText: 'Select a goal',
                  onChanged: (v) => setState(() => _selectedGoal = v),
                  validator: (v) => v == null ? 'Please select a goal' : null,
                ),

                SizedBox(height: 20.h),

                // ── Horizon ─────────────────────────────────
                _FieldLabel('Investment Horizon'),
                SizedBox(height: 8.h),
                AppDropdown<String>(
                  items: _horizonItems,
                  value: _selectedHorizon,
                  label: 'Investment Horizon',
                  hintText: 'Select a horizon',
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
