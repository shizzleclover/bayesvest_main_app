import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../controller/watchlist_controller.dart';
import '../model/watchlist_item.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final wlAsync = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref, colorScheme),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
      ),
      body: wlAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: GoogleFonts.plusJakartaSans(color: colorScheme.error)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border_rounded,
                        size: 64.w, color: colorScheme.onSurfaceVariant),
                    SizedBox(height: 16.h),
                    Text('Watchlist is empty',
                        style: GoogleFonts.manrope(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface)),
                    SizedBox(height: 8.h),
                    Text('Add tickers to track assets you\u0027re interested in.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, i) {
              return AnimatedListItem(
                index: i,
                child: _WatchlistTile(
                  item: items[i],
                  colorScheme: colorScheme,
                  onRemove: () => ref
                      .read(watchlistProvider.notifier)
                      .remove(items[i].ticker),
                  onTap: () =>
                      context.push(AppRoutes.assetDetailPath(items[i].ticker)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref, ColorScheme cs) {
    final ctrl = TextEditingController();
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
            Text('Add to Watchlist',
                style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            SizedBox(height: 16.h),
            TextField(
              controller: ctrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                  hintText: 'Ticker symbol (e.g. TSLA)'),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final t = ctrl.text.trim().toUpperCase();
                  if (t.isNotEmpty) {
                    ref.read(watchlistProvider.notifier).add(t);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistTile extends StatelessWidget {
  const _WatchlistTile({
    required this.item,
    required this.colorScheme,
    required this.onRemove,
    required this.onTap,
  });
  final WatchlistItem item;
  final ColorScheme colorScheme;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final change = item.dailyChange;
    final isPositive = change != null && change >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.ticker,
                      style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface)),
                  SizedBox(height: 2.h),
                  Text(item.name,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.currentPrice != null)
                  Text(
                    '\$${item.currentPrice!.toStringAsFixed(2)}',
                    style: GoogleFonts.manrope(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface),
                  ),
                if (change != null)
                  Text(
                    '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.bookmark_remove_rounded,
                  size: 20.w, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
