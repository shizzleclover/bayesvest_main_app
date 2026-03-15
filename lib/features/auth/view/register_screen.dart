import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/gradient_button.dart';
import '../controller/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _password = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(next.message),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
          );
      }
      // Router redirect handles navigation to onboarding for new users.
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24.h),

                  // ── Logo ──────────────────────────────────
                  Center(
                    child: Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            colorScheme.primaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.insights_rounded,
                          color: colorScheme.onPrimary,
                          size: 28.w,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  Center(
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.manrope(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      'Start your intelligent investing journey',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // ── Email ─────────────────────────────────
                  _FieldLabel('Email Address'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    decoration:
                        const InputDecoration(hintText: 'name@company.com'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // ── Password ──────────────────────────────
                  _FieldLabel('Password'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    onChanged: (v) => setState(() => _password = v),
                    decoration: InputDecoration(
                      hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 20.w,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 8) return 'Must be at least 8 characters';
                      if (!v.contains(RegExp(r'[A-Z]'))) {
                        return 'Must contain an uppercase letter';
                      }
                      if (!v.contains(RegExp(r'[a-z]'))) {
                        return 'Must contain a lowercase letter';
                      }
                      if (!v.contains(RegExp(r'[0-9]'))) {
                        return 'Must contain a number';
                      }
                      if (!v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                        return 'Must contain a special character';
                      }
                      return null;
                    },
                  ),
                  if (_password.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _PasswordStrengthMeter(
                        password: _password, colorScheme: colorScheme),
                  ],

                  SizedBox(height: 20.h),

                  // ── Confirm password ──────────────────────
                  _FieldLabel('Confirm Password'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 20.w,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm your password';
                      if (v != _passwordCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),

                  SizedBox(height: 32.h),

                  GradientButton(
                    label: 'Create Account',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),

                  SizedBox(height: 32.h),

                  // ── Login link ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(
                          'Log In',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
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

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({
    required this.password,
    required this.colorScheme,
  });
  final String password;
  final ColorScheme colorScheme;

  static const _rules = [
    _PwRule('At least 8 characters', _hasLength),
    _PwRule('One uppercase letter (A\u2013Z)', _hasUpper),
    _PwRule('One lowercase letter (a\u2013z)', _hasLower),
    _PwRule('One number (0\u20139)', _hasDigit),
    _PwRule('One special character (!@#\$...)', _hasSpecial),
  ];

  static bool _hasLength(String p) => p.length >= 8;
  static bool _hasUpper(String p) => p.contains(RegExp(r'[A-Z]'));
  static bool _hasLower(String p) => p.contains(RegExp(r'[a-z]'));
  static bool _hasDigit(String p) => p.contains(RegExp(r'[0-9]'));
  static bool _hasSpecial(String p) =>
      p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    final passed = _rules.where((r) => r.test(password)).length;
    final fraction = passed / _rules.length;

    final Color barColor;
    final String label;
    if (fraction <= 0.2) {
      barColor = const Color(0xFFEF4444);
      label = 'Very weak';
    } else if (fraction <= 0.4) {
      barColor = const Color(0xFFF97316);
      label = 'Weak';
    } else if (fraction <= 0.6) {
      barColor = const Color(0xFFF59E0B);
      label = 'Fair';
    } else if (fraction <= 0.8) {
      barColor = const Color(0xFF3B82F6);
      label = 'Good';
    } else {
      barColor = const Color(0xFF10B981);
      label = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6.h,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: barColor)),
          ],
        ),
        SizedBox(height: 10.h),
        ..._rules.map((rule) {
          final ok = rule.test(password);
          return Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              children: [
                Icon(
                  ok ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 16.w,
                  color: ok ? const Color(0xFF10B981) : colorScheme.outline,
                ),
                SizedBox(width: 8.w),
                Text(rule.label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: ok
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _PwRule {
  final String label;
  final bool Function(String) test;
  const _PwRule(this.label, this.test);
}
