import 'dart:async';
import 'dart:ui';

import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/formatter_address.dart';
import 'package:cupcake/view_model/unconfirmed_transaction_view_model.dart';
import 'package:flutter/material.dart';

class UnconfirmedTransactionView {
  UnconfirmedTransactionView({
    required final CoinWallet wallet,
    required final Amount fee,
    required final Map<Address, Amount> destMap,
    required final FutureOr<void> Function(BuildContext context) confirmCallback,
    required final FutureOr<void> Function() cancelCallback,
  }) : viewModel = UnconfirmedTransactionViewModel(
          wallet: wallet,
          fee: fee,
          destMap: destMap,
          confirmCallback: confirmCallback,
          cancelCallback: cancelCallback,
        );

  final UnconfirmedTransactionViewModel viewModel;
  AppLocalizations get L => viewModel.L;
  ThemeData get T => viewModel.T;
  Future<dynamic> pushReplacement(final BuildContext context) {
    viewModel.register(context);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (final context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: T.colorScheme.onPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _buildBottomSheet(context),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(final BuildContext context) {
    viewModel.register(context);
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.1,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Color(0xff1B284A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16, top: 16),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: T.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(512),
                        ),
                        child: IconButton(
                          onPressed: () => viewModel.cancel(),
                          icon: Icon(
                            Icons.close,
                            color: T.colorScheme.onSurface,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(76),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                viewModel.wallet.coin.strings.svg.svg(),
                const SizedBox(width: 8),
                Text(
                  L.confirm_transaction,
                  style: TextStyle(
                    color: T.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildContent(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildContent(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStandardTile(
            context,
            itemTitle: 'Fee',
            itemValue: viewModel.fee.toString(),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            itemCount: viewModel.destMap.length,
            separatorBuilder: (final context, final index) => const SizedBox(height: 8),
            itemBuilder: (final context, final index) {
              final keys = viewModel.destMap.keys.toList();
              final address = keys[index];
              final amount = viewModel.destMap[address]!;
              return _buildAddressTile(
                context,
                address: address.address,
                amount: amount.toString(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStandardTile(
    final BuildContext context, {
    required final String itemTitle,
    required final String itemValue,
    final String? itemSubTitle,
  }) {
    final itemTitleTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          decoration: TextDecoration.none,
        );
    final itemSubTitleTextStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          decoration: TextDecoration.none,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: T.colorScheme.surfaceContainer,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(itemTitle, style: itemTitleTextStyle),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(itemValue, style: itemTitleTextStyle),
              if (itemSubTitle != null) Text(itemSubTitle, style: itemSubTitleTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(
    final BuildContext context, {
    required final String address,
    required final String amount,
  }) {
    final itemTitleTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          decoration: TextDecoration.none,
        );
    final addressTextStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          decoration: TextDecoration.none,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: T.colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Address', style: itemTitleTextStyle),
              Text(amount, style: itemTitleTextStyle),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            formattedAddress(address),
            style: addressTextStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(42, 0, 42, 34),
      decoration: BoxDecoration(
        color: Color(0xff1B284A),
      ),
      child: _SlideToConfirmButton(
        onSlideComplete: () => viewModel.confirm(context),
        buttonText: L.swipe_to_confirm,
        onCancel: () => viewModel.cancel(),
      ),
    );
  }
}

class _SlideToConfirmButton extends StatefulWidget {
  const _SlideToConfirmButton({
    required this.onSlideComplete,
    required this.buttonText,
    required this.onCancel,
  });

  final VoidCallback onSlideComplete;
  final String buttonText;
  final VoidCallback onCancel;

  @override
  State<_SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<_SlideToConfirmButton> {
  double _dragPosition = 0;
  late double _maxDragDistance;
  bool _isCompleted = false;

  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (final context, final constraints) {
            _maxDragDistance = constraints.maxWidth - 42;
            return Container(
              height: 42,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: T.colorScheme.surfaceContainer,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Draggable button
                  Positioned(
                    left: _dragPosition,
                    top: 0,
                    child: GestureDetector(
                      onPanUpdate: (final details) {
                        setState(() {
                          _dragPosition += details.delta.dx;
                          _dragPosition = _dragPosition.clamp(0.0, _maxDragDistance);
                        });
                      },
                      onPanEnd: (final details) {
                        if (_dragPosition >= _maxDragDistance * 0.8) {
                          setState(() {
                            _isCompleted = true;
                            _dragPosition = _maxDragDistance;
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          widget.onSlideComplete();
                        } else {
                          setState(() {
                            _dragPosition = 0;
                          });
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: T.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            _isCompleted ? Icons.check : Icons.arrow_forward,
                            color: _isCompleted ? Colors.green : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
