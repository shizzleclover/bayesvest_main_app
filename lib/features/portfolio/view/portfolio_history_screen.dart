import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../model/portfolio.dart';

final _historyProvider = FutureProvider<List<Portfolio>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(ApiEndpoints.portfolioHistory);
  final list = response.data as List<dynamic>;
  return list
      .map((e) => Portfolio.fromJson(e as Map<String, dynamic>))
      .toList();
});

class PortfolioHistoryScreen extends ConsumerWidget {
  const PortfolioHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final historyAsync = ref.watch(_historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: GoogleFonts.plusJakartaSans(color: colorScheme.error)),
        ),
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Text('No portfolio history yet.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp, color: colorScheme.onSurfaceVariant)),
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: history.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, i) {
              final p = history[i];
              return AnimatedListItem(
                index: i,
                child: _HistoryCard(portfolio: p, colorScheme: colorScheme, index: i + 1),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({
    required this.portfolio,
    required this.colorScheme,
    required this.index,
  });
  final Portfolio portfolio;
  final ColorScheme colorScheme;
  final int index;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.portfolio;
    final cs = widget.colorScheme;
    final date = p.createdAt;
    final dateStr = date != null
        ? '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : 'Unknown date';

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      '#${widget.index}',
                      style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: cs.primary),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface)),
                      SizedBox(height: 2.h),
                      Text(
                        '${p.assetAllocation.length} assets \u2022 +${p.expectedReturn1y.toStringAsFixed(1)}% return',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(p.riskSummary,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: cs.onSurfaceVariant,
                          height: 1.5)),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: p.assetAllocation.entries.map((e) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          '${e.key} ${(e.value * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: cs.primary),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
