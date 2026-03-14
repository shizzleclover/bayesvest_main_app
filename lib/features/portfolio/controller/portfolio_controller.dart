import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../model/portfolio.dart';
import '../service/portfolio_service.dart';

final portfolioControllerProvider =
    AsyncNotifierProvider<PortfolioController, Portfolio?>(
  PortfolioController.new,
);

/// Holds an optional investment amount the user wants to allocate.
final investmentAmountProvider =
    NotifierProvider<InvestmentAmountNotifier, double?>(
  InvestmentAmountNotifier.new,
);

class InvestmentAmountNotifier extends Notifier<double?> {
  @override
  double? build() => null;

  void set(double? value) => state = value;
}

class PortfolioController extends AsyncNotifier<Portfolio?> {
  static const _tag = 'PortfolioCtrl';

  @override
  Future<Portfolio?> build() async {
    AppLogger.info('build() — fetching latest portfolio', tag: _tag);
    try {
      final service = ref.read(portfolioServiceProvider);
      final portfolio = await service.getLatestPortfolio();
      if (portfolio != null) {
        AppLogger.info(
          'loaded existing portfolio: ${portfolio.assetAllocation.length} assets',
          tag: _tag,
        );
      } else {
        AppLogger.info('no existing portfolio', tag: _tag);
      }
      return portfolio;
    } catch (e) {
      AppLogger.error('failed to load portfolio', tag: _tag, error: e);
      return null;
    }
  }

  Future<void> generate() async {
    AppLogger.info('generate() called', tag: _tag);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(portfolioServiceProvider);
      final portfolio = await service.generatePortfolio();
      AppLogger.info(
        'portfolio generated: ${portfolio.assetAllocation.length} assets, '
        'return=${portfolio.expectedReturn1y}',
        tag: _tag,
      );
      return portfolio;
    });
    if (state.hasError) {
      AppLogger.error('portfolio generation failed', tag: _tag, error: state.error);
    }
  }
}
