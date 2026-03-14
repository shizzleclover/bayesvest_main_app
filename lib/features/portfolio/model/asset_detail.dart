/// Price point for charting.
class PricePoint {
  final DateTime date;
  final double close;

  const PricePoint({required this.date, required this.close});

  factory PricePoint.fromJson(Map<String, dynamic> json) => PricePoint(
        date: DateTime.parse(json['date'] as String),
        close: (json['close'] as num).toDouble(),
      );
}

/// Prophet forecast data.
class AssetForecast {
  final double expectedReturn;
  final double volatility;
  final double? yhatUpper;
  final double? yhatLower;
  final DateTime? forecastDate;

  const AssetForecast({
    required this.expectedReturn,
    required this.volatility,
    this.yhatUpper,
    this.yhatLower,
    this.forecastDate,
  });

  factory AssetForecast.fromJson(Map<String, dynamic> json) => AssetForecast(
        expectedReturn: (json['expected_return'] as num).toDouble(),
        volatility: (json['volatility'] as num).toDouble(),
        yhatUpper: (json['yhat_upper'] as num?)?.toDouble(),
        yhatLower: (json['yhat_lower'] as num?)?.toDouble(),
        forecastDate: json['forecast_date'] != null
            ? DateTime.tryParse(json['forecast_date'] as String)
            : null,
      );
}

/// Live market stats (may be partially null depending on asset type).
class LiveStats {
  final double? currentPrice;
  final double? previousClose;
  final double? marketCap;
  final double? peRatio;
  final double? dividendYield;
  final double? fiftyTwoWeekHigh;
  final double? fiftyTwoWeekLow;
  final double? avgVolume;
  final double? beta;
  final String? description;

  const LiveStats({
    this.currentPrice,
    this.previousClose,
    this.marketCap,
    this.peRatio,
    this.dividendYield,
    this.fiftyTwoWeekHigh,
    this.fiftyTwoWeekLow,
    this.avgVolume,
    this.beta,
    this.description,
  });

  factory LiveStats.fromJson(Map<String, dynamic> json) => LiveStats(
        currentPrice: (json['current_price'] as num?)?.toDouble(),
        previousClose: (json['previous_close'] as num?)?.toDouble(),
        marketCap: (json['market_cap'] as num?)?.toDouble(),
        peRatio: (json['pe_ratio'] as num?)?.toDouble(),
        dividendYield: (json['dividend_yield'] as num?)?.toDouble(),
        fiftyTwoWeekHigh: (json['fifty_two_week_high'] as num?)?.toDouble(),
        fiftyTwoWeekLow: (json['fifty_two_week_low'] as num?)?.toDouble(),
        avgVolume: (json['avg_volume'] as num?)?.toDouble(),
        beta: (json['beta'] as num?)?.toDouble(),
        description: json['description'] as String?,
      );
}

/// Full detail payload for one asset.
class AssetDetail {
  final String ticker;
  final String name;
  final String assetClass;
  final String sector;
  final String riskLevel;
  final List<PricePoint> priceHistory;
  final AssetForecast? forecast;
  final LiveStats liveStats;

  const AssetDetail({
    required this.ticker,
    required this.name,
    required this.assetClass,
    required this.sector,
    required this.riskLevel,
    required this.priceHistory,
    this.forecast,
    required this.liveStats,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) {
    final rawPrices = json['price_history'] as List<dynamic>? ?? [];
    final rawForecast = json['forecast'] as Map<String, dynamic>?;
    final rawStats = json['live_stats'] as Map<String, dynamic>? ?? {};

    return AssetDetail(
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      assetClass: json['asset_class'] as String,
      sector: json['sector'] as String,
      riskLevel: json['risk_level'] as String,
      priceHistory: rawPrices
          .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      forecast: rawForecast != null
          ? AssetForecast.fromJson(rawForecast)
          : null,
      liveStats: LiveStats.fromJson(rawStats),
    );
  }
}
