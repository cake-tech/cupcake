import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class QrInfoScreen extends AbstractView {
  QrInfoScreen({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  String get screenName => title;

  Future<void> _openOnDevice() async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Fallback - show snackbar if URL launching fails
      if (viewModel.c != null && viewModel.mounted) {
        ScaffoldMessenger.of(viewModel.c!).showSnackBar(
          SnackBar(
            content: Text('Cannot open $title on this device'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    viewModel.register(context);
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          title: Text(screenName),
          automaticallyImplyLeading: canPop,
          leading: popButton,
        ),
        body: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  L.scan_this_qr_code_to_open(url),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LongPrimaryButton(
            text: L.open_on_this_device,
            icon: Icons.open_in_new,
            onPressed: _openOnDevice,
          ),
        ),
      ),
    );
  }
}
