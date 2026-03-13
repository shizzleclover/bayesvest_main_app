import 'package:flutter/material.dart';

class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({super.key, required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Asset Detail — $ticker')),
    );
  }
}
