import 'package:flutter/material.dart';
import 'package:jomaboi/constants.dart';
import 'package:jomaboi/pages/onboard/onboard_screen.dart';
import 'package:jomaboi/providers/authentication_provider.dart';
import 'package:jomaboi/utilities/assets_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAthentication();
    super.initState();
  }

  void checkAthentication() async {
    final authProvider = context.read<AuthenticationProvider>();
    bool isAuthenticated = await authProvider.checkAuthenticationState();

    if (mounted) {
      navigate(isAuthenticated: isAuthenticated);
    }
  }

  navigate({required bool isAuthenticated}) async {
    if (!mounted) return;

    if (isAuthenticated) {
      final authProvider = context.read<AuthenticationProvider>();
      bool userExists = await authProvider.checkUserExists();

      if (!userExists) {
        Navigator.pushReplacementNamed(context, Constants.userInformationScreen);
        return;
      }

      // Check if user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      bool hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

      if (!hasCompletedOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardScreen()),
        );
      } else {
        Navigator.pushReplacementNamed(context, Constants.mainScreen);
      }
    } else {
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400,
          width: 200,
          child: Column(
            children: [
              Lottie.asset(AssetsMenager.chatBubble),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
