import 'package:jomaboi/helpers/color.helper.dart';
import 'package:jomaboi/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback onGetStarted;
  const LandingPage({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "JomaBoi",
                style: theme.textTheme.headlineLarge!.apply(
                    color: theme.colorScheme.primary, fontWeightDelta: 1),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Easily manage and complete your saving goals",
                style: theme.textTheme.headlineMedium!.apply(
                    color: ColorHelper.lighten(theme.colorScheme.primary, 0.1)),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Expanded(
                      child: Text(
                          "JomaBoi is the trusted partner to reach your saving goals."))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Expanded(
                      child: Text(
                          "Monitor your expenses to effictively manage the budget."))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Expanded(
                    child: Text(
                        "Keep track of your finances whenever and wherever you are."),
                  )
                ],
              ),
              const Expanded(child: SizedBox()),
              const Text(
                  "*The application is in beta. Live version will be released soon."),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: AppButton(
                  color: theme.colorScheme.inversePrimary,
                  isFullWidth: true,
                  onPressed: onGetStarted,
                  size: AppButtonSize.large,
                  label: "Get Started",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
