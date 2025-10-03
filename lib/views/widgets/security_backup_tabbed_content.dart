import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/view_model/security_backup_view_model.dart';
import 'package:cupcake/views/widgets/guarded_gesture_detector.dart';
import 'package:cupcake/views/widgets/seed_grid.dart';
import 'package:cupcake/views/widgets/yellow_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityBackupTabbedContent extends StatefulWidget {
  const SecurityBackupTabbedContent({
    super.key,
    required this.viewModel,
    required this.getDetails,
    required this.L,
  });
  final SecurityBackupViewModel viewModel;
  final Future<List<WalletSeedDetail>> Function() getDetails;
  final AppLocalizations L;

  @override
  State<SecurityBackupTabbedContent> createState() => _SecurityBackupTabbedContentState();
}

class _SecurityBackupTabbedContentState extends State<SecurityBackupTabbedContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  AppLocalizations get L => widget.L;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        YellowWarning(text: L.do_not_share_notice),
        Padding(
          padding: const EdgeInsets.only(left: 22, right: 22, top: 0),
          child: TabBar(
            controller: _tabController,
            splashFactory: NoSplash.splashFactory,
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(128),
                ),
            labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.only(right: 24),
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            padding: EdgeInsets.zero,
            tabs: [
              Tab(text: L.seed),
              Tab(text: L.keys),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSeedTab(context),
              _buildKeysTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeedTab(final BuildContext context) {
    return FutureBuilder<List<WalletSeedDetail>>(
      future: widget.getDetails(),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.error != null) {
            return Text(snapshot.error.toString());
          }
          return const Center(child: CircularProgressIndicator());
        }

        final seedDetails = snapshot.data!.where((final detail) => _isSeedDetail(detail)).toList();
        final seedWords = seedDetails.isNotEmpty
            ? seedDetails.first.value.split(' ').where((final word) => word.isNotEmpty).toList()
            : <String>[];

        return Padding(
          padding: const EdgeInsets.only(left: 22, right: 22),
          child: Column(
            children: [
              if (seedWords.isNotEmpty) ...[
                SizedBox(height: 24),
                Expanded(
                  child: SeedPhraseGridWidget(list: seedWords),
                ),
                const SizedBox(height: 10),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Text(L.no_seed_available),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeysTab(final BuildContext context) {
    return FutureBuilder<List<WalletSeedDetail>>(
      future: widget.getDetails(),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.error != null) {
            return Text(snapshot.error.toString());
          }
          return const Center(child: CircularProgressIndicator());
        }

        final keyDetails = snapshot.data!.where((final detail) => !_isSeedDetail(detail)).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: keyDetails.length,
                  itemBuilder: (final context, final index) {
                    final item = keyDetails[index];
                    return _buildTextInfoBox(context, item);
                  },
                  separatorBuilder: (final context, final index) => const SizedBox(height: 20),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextInfoBox(final BuildContext context, final WalletSeedDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                detail.name,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(128),
                    ),
              ),
              GuardedGestureDetector(
                onTap: () => Clipboard.setData(ClipboardData(text: detail.value)),
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(179),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail.value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  bool _isSeedDetail(final WalletSeedDetail detail) => detail.name.toLowerCase().contains('seed');
}
