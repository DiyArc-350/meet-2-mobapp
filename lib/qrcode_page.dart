import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String _generatedUrl = "";
  String _scannedUrl = "Scan a QR code to see the result";

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _downloadQrCode() async {
    if (_generatedUrl.isEmpty) return;

    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code saved to gallery')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving QR Code: $e')));
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_scannedUrl == "Scan a QR code to see the result") return;

    await Clipboard.setData(ClipboardData(text: _scannedUrl));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    }
  }

  Future<void> _openLink() async {
    if (_scannedUrl == "Scan a QR code to see the result") return;

    String url = _scannedUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          // Fallback to platform default if external application fails
          if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
            throw 'Could not launch $url';
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not launch URL: $e')));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid URL')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QR Code'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.qr_code), text: 'Generate'),
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Generate Tab
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  const SizedBox(height: 40),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Enter URL',
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _generatedUrl = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  if (_generatedUrl.isNotEmpty) ...[
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        color: Colors.white, // Ensure white background
                        child: QrImageView(
                          data: _generatedUrl,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _downloadQrCode,
                      icon: const Icon(Icons.download),
                      label: const Text('Download QR Code'),
                    ),
                  ] else
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Enter a URL to generate QR Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Scan Tab
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          setState(() {
                            _scannedUrl = barcode.rawValue!;
                          });
                        }
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Scanned Result:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _scannedUrl,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_scannedUrl !=
                                "Scan a QR code to see the result") ...[
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: _copyToClipboard,
                                tooltip: 'Copy to clipboard',
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: _openLink,
                                tooltip: 'Open Link',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
