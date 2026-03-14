import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/watchlist_item.dart';

final watchlistProvider =
    AsyncNotifierProvider<WatchlistController, List<WatchlistItem>>(
  WatchlistController.new,
);

class WatchlistController extends AsyncNotifier<List<WatchlistItem>> {
  @override
  Future<List<WatchlistItem>> build() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(ApiEndpoints.watchlist);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => WatchlistItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(String ticker) async {
    final dio = ref.read(dioProvider);
    await dio.post(ApiEndpoints.watchlistAdd, data: {'ticker': ticker});
    ref.invalidateSelf();
  }

  Future<void> remove(String ticker) async {
    final dio = ref.read(dioProvider);
    await dio.post(ApiEndpoints.watchlistRemove, data: {'ticker': ticker});
    ref.invalidateSelf();
  }
}
