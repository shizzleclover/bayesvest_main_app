import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/portfolio.dart';
import '../service/portfolio_service.dart';

final portfolioControllerProvider =
    AsyncNotifierProvider<PortfolioController, Portfolio?>(
  PortfolioController.new,
);

class PortfolioController extends AsyncNotifier<Portfolio?> {
  @override
  Future<Portfolio?> build() async => null;

  Future<void> generate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(portfolioServiceProvider);
      return await service.generatePortfolio();
    });
  }
}
