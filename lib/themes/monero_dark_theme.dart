import 'package:cup_cake/themes/dark_theme.dart';
import 'package:cup_cake/themes/extensions/account_list_theme.dart';
import 'package:cup_cake/themes/extensions/address_theme.dart';
import 'package:cup_cake/themes/extensions/alert_theme.dart';
import 'package:cup_cake/themes/extensions/balance_page_theme.dart';
import 'package:cup_cake/themes/extensions/cake_scrollbar_theme.dart';
import 'package:cup_cake/themes/extensions/cake_text_theme.dart';
import 'package:cup_cake/themes/extensions/dashboard_page_theme.dart';
import 'package:cup_cake/themes/extensions/exchange_page_theme.dart';
import 'package:cup_cake/themes/extensions/filter_theme.dart';
import 'package:cup_cake/themes/extensions/indicator_dot_theme.dart';
import 'package:cup_cake/themes/extensions/info_theme.dart';
import 'package:cup_cake/themes/extensions/keyboard_theme.dart';
import 'package:cup_cake/themes/extensions/menu_theme.dart';
import 'package:cup_cake/themes/extensions/new_wallet_theme.dart';
import 'package:cup_cake/themes/extensions/option_tile_theme.dart';
import 'package:cup_cake/themes/extensions/order_theme.dart';
import 'package:cup_cake/themes/extensions/picker_theme.dart';
import 'package:cup_cake/themes/extensions/pin_code_theme.dart';
import 'package:cup_cake/themes/extensions/placeholder_theme.dart';
import 'package:cup_cake/themes/extensions/qr_code_theme.dart';
import 'package:cup_cake/themes/extensions/receive_page_theme.dart';
import 'package:cup_cake/themes/extensions/seed_widget_theme.dart';
import 'package:cup_cake/themes/extensions/send_page_theme.dart';
import 'package:cup_cake/themes/extensions/support_page_theme.dart';
import 'package:cup_cake/themes/extensions/sync_indicator_theme.dart';
import 'package:cup_cake/themes/extensions/transaction_trade_theme.dart';
import 'package:cup_cake/themes/extensions/wallet_list_theme.dart';
import 'package:cup_cake/themes/palette.dart';
import 'package:flutter/material.dart';

class MoneroDarkTheme extends DarkTheme {
  MoneroDarkTheme({required int raw}) : super(raw: raw);

  @override
  String get title => "Monero dark theme";
  @override
  Color get backgroundColor => Colors.black;
  @override
  Color get primaryColor => PaletteDark.moneroOrange;
  @override
  Color get containerColor => PaletteDark.moneroCard;
  @override
  Color get dialogBackgroundColor => containerColor;

  @override
  CakeScrollbarTheme get scrollbarTheme =>
      super.scrollbarTheme.copyWith(thumbColor: Colors.grey);

  @override
  SyncIndicatorTheme get syncIndicatorStyle =>
      super.syncIndicatorStyle.copyWith(
          textColor: Colors.white,
          notSyncedBackgroundColor: Colors.grey.withOpacity(0.2),
          syncedBackgroundColor: containerColor);

  @override
  PinCodeTheme get pinCodeTheme => super
      .pinCodeTheme
      .copyWith(indicatorsColor: primaryColor, switchColor: Colors.grey);

  @override
  ExchangePageTheme get exchangePageTheme => super.exchangePageTheme.copyWith(
      hintTextColor: Colors.grey,
      qrCodeColor: primaryTextColor,
      buttonBackgroundColor: colorScheme.surfaceVariant,
      textFieldButtonColor: colorScheme.onInverseSurface,
      textFieldBorderBottomPanelColor: colorScheme.surfaceVariant,
      textFieldBorderTopPanelColor: colorScheme.surfaceVariant,
      secondGradientBottomPanelColor: containerColor,
      firstGradientBottomPanelColor: containerColor,
      secondGradientTopPanelColor: colorScheme.surface,
      firstGradientTopPanelColor: colorScheme.surface,
      receiveAmountColor: colorScheme.surfaceVariant);

  @override
  NewWalletTheme get newWalletTheme => super
      .newWalletTheme
      .copyWith(hintTextColor: Colors.grey, underlineColor: Colors.grey);

  @override
  AddressTheme get addressTheme =>
      super.addressTheme.copyWith(actionButtonColor: containerColor);

  @override
  DashboardPageTheme get dashboardPageTheme =>
      super.dashboardPageTheme.copyWith(
          pageTitleTextColor: primaryColor,
          mainActionsIconColor: primaryColor,
          indicatorDotTheme: IndicatorDotTheme(
              indicatorColor: colorScheme.secondaryContainer,
              activeIndicatorColor: colorScheme.inversePrimary));
  @override
  BalancePageTheme get balancePageTheme => super.balancePageTheme.copyWith(
      cardBorderColor: primaryColor.withOpacity(0.2),
      labelTextColor: Colors.grey,
      balanceAmountColor: primaryColor,
      assetTitleColor: primaryColor);

  @override
  CakeMenuTheme get menuTheme => super.menuTheme.copyWith(
      headerFirstGradientColor: primaryColor,
      headerSecondGradientColor: containerColor,
      backgroundColor: containerColor,
      subnameTextColor: Colors.grey,
      dividerColor: colorScheme.secondaryContainer,
      iconColor: Colors.white,
      settingActionsIconColor: colorScheme.secondaryContainer);

  @override
  FilterTheme get filterTheme => super.filterTheme.copyWith(
      checkboxFirstGradientColor: colorScheme.secondaryContainer,
      checkboxSecondGradientColor: colorScheme.inversePrimary,
      checkboxBoundsColor: PaletteDark.wildVioletBlue,
      checkboxBackgroundColor: PaletteDark.wildVioletBlue.withOpacity(0.3),
      buttonColor: containerColor,
      iconColor: Colors.grey);

  @override
  WalletListTheme get walletListTheme => super.walletListTheme.copyWith(
      restoreWalletButtonTextColor: Colors.white,
      createNewWalletButtonBackgroundColor: primaryColor);

  @override
  InfoTheme get infoTheme => super.infoTheme.copyWith(textColor: Colors.grey);

  @override
  PickerTheme get pickerTheme =>
      super.pickerTheme.copyWith(dividerColor: Colors.grey.withOpacity(0.5));

  @override
  SendPageTheme get sendPageTheme => super.sendPageTheme.copyWith(
      templateNewTextColor:
      dashboardPageTheme.indicatorDotTheme.activeIndicatorColor,
      templateTitleColor: primaryTextColor,
      templateBackgroundColor: containerColor,
      templateDottedBorderColor: colorScheme.primaryContainer,
      templateSelectedCurrencyTitleColor: Colors.black,
      textFieldButtonIconColor: colorScheme.inverseSurface,
      textFieldButtonColor: colorScheme.onInverseSurface,
      textFieldHintColor: Colors.grey.withOpacity(0.5),
      textFieldBorderColor: Colors.grey.withOpacity(0.5),
      secondGradientColor: containerColor,
      firstGradientColor: containerColor,
      indicatorDotColor: dashboardPageTheme.indicatorDotTheme.indicatorColor);

  @override
  SeedWidgetTheme get seedWidgetTheme =>
      super.seedWidgetTheme.copyWith(hintTextColor: Colors.grey);

  @override
  TransactionTradeTheme get transactionTradeTheme => super
      .transactionTradeTheme
      .copyWith(detailsTitlesColor: Colors.grey, rowsColor: containerColor);

  @override
  CakeTextTheme get cakeTextTheme => super.cakeTextTheme.copyWith(
      secondaryTextColor: Colors.grey,
      addressButtonBorderColor: primaryColor.withOpacity(0.2),
      dateSectionRowColor: Colors.grey,
      textfieldUnderlineColor: Colors.grey.withOpacity(0.5));

  @override
  AccountListTheme get accountListTheme =>
      super.accountListTheme.copyWith(tilesBackgroundColor: containerColor);

  @override
  ReceivePageTheme get receivePageTheme => super.receivePageTheme.copyWith(
      currentTileBackgroundColor: primaryColor,
      currentTileTextColor: Colors.white,
      tilesBackgroundColor: containerColor,
      iconsBackgroundColor: colorScheme.onInverseSurface,
      iconsColor: colorScheme.inverseSurface,
      amountBottomBorderColor: Colors.grey,
      amountHintTextColor: Colors.grey);

  @override
  QRCodeTheme get qrCodeTheme => QRCodeTheme(
      qrCodeColor: Colors.grey, qrWidgetCopyButtonColor: Colors.grey);

  @override
  AlertTheme get alertTheme => super
      .alertTheme
      .copyWith(backdropColor: colorScheme.surface.withOpacity(0.75));

  @override
  ThemeData get themeData => super.themeData.copyWith(
      dividerColor: pickerTheme.dividerColor,
      hintColor: Colors.grey,
      dialogTheme:
      super.themeData.dialogTheme.copyWith(backgroundColor: containerColor),
      appBarTheme: super.themeData.appBarTheme.copyWith(
          titleTextStyle: super
              .themeData
              .appBarTheme
              .titleTextStyle!
              .copyWith(color: primaryColor)));
}
