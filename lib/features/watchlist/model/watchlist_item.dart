class WatchlistItem {
  final String ticker;
  final String name;
  final String assetClass;
  final double? currentPrice;
  final double? previousClose;

  const WatchlistItem({
    required this.ticker,
    required this.name,
    required this.assetClass,
    this.currentPrice,
    this.previousClose,
  });

  double? get dailyChange {
    if (currentPrice == null || previousClose == null || previousClose == 0) {
      return null;
    }
    return ((currentPrice! - previousClose!) / previousClose!) * 100;
  }

  factory WatchlistItem.fromJson(Map<String, dynamic> json) => WatchlistItem(
        ticker: json['ticker'] as String,
        name: json['name'] as String? ?? '',
        assetClass: json['asset_class'] as String? ?? '',
        currentPrice: (json['current_price'] as num?)?.toDouble(),
        previousClose: (json['previous_close'] as num?)?.toDouble(),
      );
}
