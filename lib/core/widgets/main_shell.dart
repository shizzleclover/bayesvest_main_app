import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'walkthrough_overlay.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _showWalkthrough = false;

  @override
  void initState() {
    super.initState();
    _checkWalkthrough();
  }

  Future<void> _checkWalkthrough() async {
    final show = await shouldShowWalkthrough();
    if (show && mounted) setState(() => _showWalkthrough = true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          body: widget.navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) =>
                widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            ),
            backgroundColor: colorScheme.surfaceContainerLowest,
            indicatorColor:
                colorScheme.primaryContainer.withValues(alpha: 0.12),
            elevation: 0,
            animationDuration: const Duration(milliseconds: 400),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.pie_chart_outline_rounded),
                selectedIcon: Icon(Icons.pie_chart_rounded),
                label: 'Portfolio',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
        if (_showWalkthrough)
          WalkthroughOverlay(
            onComplete: () => setState(() => _showWalkthrough = false),
          ),
      ],
    );
  }
}
