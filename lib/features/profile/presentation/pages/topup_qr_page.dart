import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:app1/services/payment_service.dart';

class TopUpQRPage extends StatefulWidget {
  final String qrString;
  final double amount;
  final String md5;

  const TopUpQRPage({
    super.key,
    required this.qrString,
    required this.amount,
    required this.md5,
  });

  @override
  State<TopUpQRPage> createState() => _TopUpQRPageState();
}

class _TopUpQRPageState extends State<TopUpQRPage> {
  Timer? _statusTimer;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _startPollingStatus();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startPollingStatus() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final statusResult = await PaymentService.checkTopUpStatus(widget.md5);
        if (statusResult != null && statusResult['status'] == 'PAID') {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isPaid = true;
            });
            // Auto close after showing success for a brief moment
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.pop(context, true);
            });
          }
        }
      } catch (e) {
        debugPrint("Error polling status: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Scan to Top Up"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isPaid) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 100),
                const SizedBox(height: 24),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Your wallet balance will be updated shortly."),
              ] else ...[
                const Text(
                  "KHQR Payment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Amount: \$${widget.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF6600),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: widget.qrString,
                    version: QrVersions.auto,
                    size: 280.0,
                  ),
                ),
                const SizedBox(height: 32),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Scan this KHQR with any mobile banking app",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF6600)),
                      foregroundColor: const Color(0xFFFF6600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancel Payment"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
