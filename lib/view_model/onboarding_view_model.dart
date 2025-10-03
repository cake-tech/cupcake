import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'onboarding_view_model.g.dart';

class OnboardingViewModel = OnboardingViewModelBase with _$OnboardingViewModel;

abstract class OnboardingViewModelBase extends ViewModel with Store {
  @override
  String get screenName => "Welcome to Cupcake";

  @override
  bool get hasBackground => true;

  @observable
  int currentPage = 0;

  late PageController pageController = PageController();

  @computed
  bool get isFirstPage => currentPage == 0;

  @computed
  bool get isLastPage => currentPage == pages.length - 1;

  @computed
  bool get showSkipButton => !isLastPage;

  @action
  void nextPage() {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @action
  void skipToEnd() {
    pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @action
  void onPageChanged(final int page) {
    currentPage = page;
  }

  Future<void> onContinue() {
    return CreateWallet(
      viewModel: CreateWalletViewModel(createMethod: null, needsPasswordConfirm: true),
    ).push(c!);
  }

  List<OnboardingPageData> get pages => [
        OnboardingPageData(
          description: L.onboarding_page_1,
        ),
        OnboardingPageData(
          description: L.onboarding_page_2,
        ),
        OnboardingPageData(
          description: L.onboarding_page_3,
        ),
      ];
}

class OnboardingPageData {
  OnboardingPageData({
    required this.description,
  });
  final String description;
}
