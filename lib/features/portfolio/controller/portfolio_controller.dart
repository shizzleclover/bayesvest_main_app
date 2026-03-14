import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../model/portfolio.dart';
import '../service/portfolio_service.dart';

final portfolioControllerProvider =
    AsyncNotifierProvider<PortfolioController, Portfolio?>(
  PortfolioController.new,
);

class PortfolioController extends AsyncNotifier<Portfolio?> {
  static const _tag = 'PortfolioCtrl';

  @override
  Future<Portfolio?> build() async => null;

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
