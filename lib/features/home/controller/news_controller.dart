import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/news_article.dart';

final newsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(ApiEndpoints.marketNews);
  final list = response.data as List<dynamic>;
  return list
      .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
      .toList();
});
