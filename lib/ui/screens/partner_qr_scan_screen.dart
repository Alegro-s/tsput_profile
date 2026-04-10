import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers/partner_services_provider.dart';

/// Сканирование QR-кода услуги партнёра (данные уходят на бэкенд).
class PartnerQrScanScreen extends StatefulWidget {
  const PartnerQrScanScreen({super.key});

  @override
  State<PartnerQrScanScreen> createState() => _PartnerQrScanScreenState();
}

class _PartnerQrScanScreenState extends State<PartnerQrScanScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.blockBlack,
      appBar: AppBar(
        title: const Text('Скан услуги'),
        backgroundColor: AppConstants.blockBlack,
        foregroundColor: AppConstants.onBlock,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              if (_handled || !mounted) return;
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final raw = barcodes.first.rawValue;
              if (raw == null || raw.isEmpty) return;
              _handled = true;
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final partner = context.read<PartnerServicesProvider>();
              try {
                await partner.registerScan(raw);
                if (!mounted) return;
                nav.pop(true);
              } catch (e) {
                _handled = false;
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(content: Text('$e')));
              }
            },
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Text(
              'Наведите камеру на QR партнёра. Данные передаются на платформу по защищённому API.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
