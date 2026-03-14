import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/currency_toggle.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../onboarding/controller/onboarding_controller.dart';
import '../../onboarding/model/financial_profile.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController();
  String? _selectedGoal;
  String? _selectedHorizon;
  bool _saving = false;
  bool _prefilled = false;

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

  static const _goalValues = [
    'Retirement',
    'Home Purchase',
    'Education',
    'Wealth Building',
    'Other',
  ];

  static const _horizonValues = [
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

  void _prefill(FinancialProfile profile) {
    if (_prefilled) return;
    _prefilled = true;
    if (profile.age != null) _ageCtrl.text = profile.age.toString();
    if (profile.income != null) {
      _incomeCtrl.text = profile.income!.toStringAsFixed(0);
    }
    if (profile.savings != null) {
      _savingsCtrl.text = profile.savings!.toStringAsFixed(0);
    }
    _selectedGoal =
        _goalValues.contains(profile.goals) ? profile.goals : null;
    _selectedHorizon =
        _horizonValues.contains(profile.horizon) ? profile.horizon : null;
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

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(profileControllerProvider);
    final currency = ref.watch(currencyProvider);

    profileAsync.whenData((p) {
      if (p != null) _prefill(p);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),

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
                  label: 'Save',
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
