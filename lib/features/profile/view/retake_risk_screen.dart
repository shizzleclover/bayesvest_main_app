import 'package:flutter/material.dart';

import '../../onboarding/view/risk_questionnaire_screen.dart';

/// Wraps the same questionnaire UI with [isRetake: true]
/// so it pops back to Profile instead of navigating to /home.
class RetakeRiskScreen extends StatelessWidget {
  const RetakeRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RiskQuestionnaireScreen(isRetake: true);
  }
}
