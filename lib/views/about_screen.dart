import 'package:cupcake/view_model/about_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/qr_info_screen.dart';
import 'package:cupcake/views/widgets/about/about_button_group_widget.dart';
import 'package:cupcake/views/widgets/about/about_button_widget.dart';
import 'package:cupcake/views/widgets/about/app_header_widget.dart';
import 'package:cupcake/views/widgets/about/made_with_love_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AboutScreen extends AbstractView {
  AboutScreen({super.key}) : viewModel = AboutViewModel();

  @override
  AboutViewModel viewModel;

  @override
  Future<void> initState(final BuildContext context) async {
    await viewModel.loadAppInfo();
  }

  void _openQrScreen(
    final BuildContext context,
    final String title,
    final String url,
  ) {
    QrInfoScreen(
      title: title,
      url: url,
    ).push(context);
  }

  @override
  Widget build(final BuildContext context) {
    viewModel.register(context);
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          title: Text(viewModel.screenName),
          automaticallyImplyLeading: canPop,
          leading: popButton,
        ),
        body: Observer(
          builder: (final context) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  AppHeaderWidget(
                    appName: viewModel.appName,
                    fullVersion: viewModel.fullVersion,
                  ),
                  const SizedBox(height: 8),
                  const MadeWithLoveWidget(),
                  const SizedBox(height: 48),
                  AboutButtonGroupWidget(
                    buttons: [
                      AboutButtonWidget(
                        text: L.view_changelog,
                        isFirst: true,
                        onPressed: () => _openQrScreen(
                          context,
                          L.view_changelog,
                          "https://github.com/cake-tech/cupcake/releases",
                        ),
                      ),
                      AboutButtonWidget(
                        text: L.install_cake_wallet,
                        onPressed: () => _openQrScreen(
                          context,
                          L.install_cake_wallet,
                          "https://cakewallet.com/install",
                        ),
                      ),
                      AboutButtonWidget(
                        text: L.docs,
                        isLast: true,
                        onPressed: () => _openQrScreen(
                          context,
                          L.documentation,
                          "https://docs.cakewallet.com",
                        ),
                      ),
                      AboutButtonWidget(
                        text: L.license,
                        isLast: true,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (final BuildContext context) => LicensePage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  AboutButtonGroupWidget(
                    buttons: [
                      AboutButtonWidget(
                        text: L.github,
                        isFirst: true,
                        onPressed: () => _openQrScreen(
                          context,
                          L.github,
                          "https://github.com/cake-tech/cupcake",
                        ),
                      ),
                      AboutButtonWidget(
                        text: L.x_twitter,
                        onPressed: () => _openQrScreen(
                          context,
                          L.x_twitter,
                          "https://x.com/cakewallet",
                        ),
                      ),
                      AboutButtonWidget(
                        text: L.telegram,
                        isLast: true,
                        onPressed: () => _openQrScreen(
                          context,
                          L.telegram,
                          "https://t.me/cakewalletannouncements",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
