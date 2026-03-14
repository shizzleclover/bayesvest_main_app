/// Re-exports the shared profile and risk controllers so the
/// profile feature screens can import from a single location.
export '../../onboarding/controller/onboarding_controller.dart'
    show
        profileControllerProvider,
        ProfileController,
        riskControllerProvider,
        RiskController;
