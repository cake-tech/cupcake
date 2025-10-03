import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/view_model/onboarding_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class OnboardingScreen extends AbstractView {
  OnboardingScreen({super.key});

  @override
  OnboardingViewModel viewModel = OnboardingViewModel();

  @override
  Widget? body(final BuildContext context) {
    return Observer(
      builder: (final context) {
        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: viewModel.pageController,
                onPageChanged: viewModel.onPageChanged,
                itemCount: viewModel.pages.length,
                itemBuilder: (final context, final index) {
                  final pageData = viewModel.pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        _getIconForPage(index),
                        const SizedBox(height: 24),
                        Text(
                          pageData.description,
                          style: T.textTheme.bodyLarge?.copyWith(
                            color: T.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Observer(
              builder: (final context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(viewModel.pages.length, (final index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == viewModel.currentPage
                            ? T.colorScheme.primary
                            : T.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return Observer(
      builder: (final context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (viewModel.showSkipButton)
              LongSecondaryButton(
                T,
                text: L.skip,
                onPressed: viewModel.skipToEnd,
              ),
            LongPrimaryButton(
              text: viewModel.isLastPage ? L.continue_ : L.next,
              onPressed: viewModel.isLastPage ? viewModel.onContinue : viewModel.nextPage,
            ),
          ],
        );
      },
    );
  }

  Widget _getIconForPage(final int page) {
    switch (page) {
      case 0:
        return Assets.icons.cupcakeCakeAirgap.image();
      case 1:
        return Assets.icons.cupcakeCakeQr.image();
      case 2:
        return Assets.icons.secureStorage.image();
      default:
        return Text("unknown icon for index: $page");
    }
  }
}
