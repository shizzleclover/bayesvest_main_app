import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../controller/goals_controller.dart';
import '../model/savings_goal.dart';

const _goalIcons = <String, IconData>{
  'savings': Icons.savings_rounded,
  'home': Icons.home_rounded,
  'retirement': Icons.elderly_rounded,
  'education': Icons.school_rounded,
  'travel': Icons.flight_rounded,
  'car': Icons.directions_car_rounded,
  'emergency': Icons.health_and_safety_rounded,
  'custom': Icons.flag_rounded,
};

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final goalsAsync = ref.watch(goalsProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(context, ref, colorScheme, currency),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: GoogleFonts.plusJakartaSans(color: colorScheme.error)),
        ),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag_outlined,
                        size: 64.w, color: colorScheme.onSurfaceVariant),
                    SizedBox(height: 16.h),
                    Text('No goals yet',
                        style: GoogleFonts.manrope(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface)),
                    SizedBox(height: 8.h),
                    Text(
                      'Set a savings goal to track your progress toward what matters most.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: goals.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, i) {
              return AnimatedListItem(
                index: i,
                child: _GoalCard(
                  goal: goals[i],
                  currency: currency,
                  colorScheme: colorScheme,
                  onDelete: () =>
                      ref.read(goalsProvider.notifier).deleteGoal(goals[i].id),
                  onUpdateAmount: (amount) =>
                      ref.read(goalsProvider.notifier).updateGoal(
                        goals[i].id,
                        {'current_amount': amount},
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddGoalSheet(
      BuildContext context, WidgetRef ref, ColorScheme cs, AppCurrency currency) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final monthlyCtrl = TextEditingController();
    var selectedIcon = 'savings';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20.w, 20.h, 20.w, MediaQuery.of(ctx).viewInsets.bottom + 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Goal',
                  style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
              SizedBox(height: 20.h),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Goal name (e.g. House)'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: targetCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: InputDecoration(
                  hintText: 'Target amount',
                  prefixText: '${currency.symbol} ',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: monthlyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: InputDecoration(
                  hintText: 'Monthly contribution',
                  prefixText: '${currency.symbol} ',
                ),
              ),
              SizedBox(height: 16.h),
              Text('Icon',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp, color: cs.onSurfaceVariant)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 10.w,
                children: _goalIcons.entries.map((e) {
                  final sel = e.key == selectedIcon;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedIcon = e.key),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: sel
                            ? cs.primary.withValues(alpha: 0.12)
                            : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(e.value,
                          size: 20.w,
                          color: sel ? cs.primary : cs.onSurfaceVariant),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final target =
                        double.tryParse(targetCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || target <= 0) return;
                    ref.read(goalsProvider.notifier).addGoal(
                      name: name,
                      targetAmount: target,
                      monthlyContribution:
                          double.tryParse(monthlyCtrl.text.trim()) ?? 0,
                      icon: selectedIcon,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Create Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Goal Card ─────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.currency,
    required this.colorScheme,
    required this.onDelete,
    required this.onUpdateAmount,
  });
  final SavingsGoal goal;
  final AppCurrency currency;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;
  final ValueChanged<double> onUpdateAmount;

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progress * 100).toStringAsFixed(0);
    final icon = _goalIcons[goal.icon] ?? Icons.flag_rounded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 22.w, color: colorScheme.primary),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: GoogleFonts.manrope(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface)),
                    SizedBox(height: 2.h),
                    Text(
                      '${formatAmount(goal.currentAmount, currency)} of ${formatAmount(goal.targetAmount, currency)}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Progress ring
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 44.w,
                      height: 44.w,
                      child: CircularProgressIndicator(
                        value: goal.progress,
                        strokeWidth: 4,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        color: goal.isOnTrack
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    Text('$pct%',
                        style: GoogleFonts.manrope(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 6.h,
              backgroundColor: colorScheme.surfaceContainerHigh,
              color: goal.isOnTrack
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.isOnTrack ? 'On track' : 'Behind schedule',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: goal.isOnTrack
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showUpdateSheet(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text('Update',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline_rounded,
                        size: 18.w, color: colorScheme.error),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpdateSheet(BuildContext context) {
    final ctrl = TextEditingController(
        text: goal.currentAmount.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20.w, 20.h, 20.w, MediaQuery.of(ctx).viewInsets.bottom + 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update ${goal.name}',
                style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface)),
            SizedBox(height: 16.h),
            TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Current amount saved',
                prefixText: '${currency.symbol} ',
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final v = double.tryParse(ctrl.text.trim());
                  if (v != null) {
                    onUpdateAmount(v);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
