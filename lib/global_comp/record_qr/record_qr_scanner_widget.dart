import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:collection/collection.dart';

import '/flutter_flow/flutter_flow_theme.dart';

class RecordQrScannerWidget extends StatefulWidget {
  const RecordQrScannerWidget({super.key, required this.expectedValue});

  final String expectedValue;

  @override
  State<RecordQrScannerWidget> createState() => _RecordQrScannerWidgetState();
}

class _RecordQrScannerWidgetState extends State<RecordQrScannerWidget> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (value == null) return;

    if (value == widget.expectedValue) {
      _handled = true;
      Navigator.of(context).pop(true);
      return;
    }

    _handled = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Этот QR-код относится к другой записи')),
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) _handled = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Сканирование QR'),
        actions: [
          IconButton(
            tooltip: 'Вспышка',
            onPressed: _controller.toggleTorch,
            icon: const Icon(Icons.flash_on_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Text(
              'Наведите камеру на QR-код записи',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
