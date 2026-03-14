import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/dimensions.dart';

/// A dropdown item with an optional icon.
class AppDropdownItem<T> {
  const AppDropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

/// A polished dropdown field that opens a modal bottom sheet.
///
/// Replaces the default [DropdownButtonFormField] with a bottom-sheet
/// picker: large tap targets, option cards, a check icon on the
/// selected value, and smooth sheet-style animation.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hintText = 'Select',
    this.validator,
    this.enabled = true,
  });

  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String hintText;
  final String? Function(T?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final selectedItem =
        value != null ? items.cast<AppDropdownItem<T>?>().firstWhere(
          (i) => i?.value == value, orElse: () => null) : null;

    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: enabled
                  ? () async {
                      final result = await _showPicker(context);
                      if (result != null) {
                        onChanged(result);
                        field.didChange(result);
                      }
                    }
                  : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: hintText,
                  errorText: field.errorText,
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 22.w,
                  ),
                ),
                child: selectedItem != null
                    ? Row(
                        children: [
                          if (selectedItem.icon != null) ...[
                            Icon(selectedItem.icon,
                                size: 18.w, color: colorScheme.primary),
                            SizedBox(width: 10.w),
                          ],
                          Expanded(
                            child: Text(
                              selectedItem.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<T?> _showPicker(BuildContext context) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (ctx) => _PickerSheet<T>(
        items: items,
        selectedValue: value,
        title: label ?? hintText,
      ),
    );
  }
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.items,
    required this.selectedValue,
    required this.title,
  });

  final List<AppDropdownItem<T>> items;
  final T? selectedValue;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: AppRadius.pill,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Options
            ...items.map((item) {
              final isSelected = item.value == selectedValue;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(item.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                              .withValues(alpha: 0.10)
                          : colorScheme.surfaceContainerLow,
                      borderRadius: AppRadius.input,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: (isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              item.icon,
                              size: 18.w,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 14.w),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  item.subtitle!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: colorScheme.primary, size: 22.w),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
