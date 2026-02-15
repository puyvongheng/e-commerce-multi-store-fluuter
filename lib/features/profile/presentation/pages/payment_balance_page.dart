import 'package:flutter/material.dart';
import 'package:app1/services/payment_service.dart';
import 'package:intl/intl.dart';
import 'package:app1/features/profile/presentation/pages/topup_qr_page.dart';
import 'dart:async';

class PaymentBalancePage extends StatefulWidget {
  const PaymentBalancePage({super.key});

  @override
  State<PaymentBalancePage> createState() => _PaymentBalancePageState();
}

class _PaymentBalancePageState extends State<PaymentBalancePage> {
  double _balance = 0.00;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWalletData() async {
    setState(() => _isLoading = true);
    final data = await PaymentService.getWalletData();
    if (mounted && data != null) {
      setState(() {
        _balance = double.tryParse(data['balance'].toString()) ?? 0.0;
        _transactions = data['transactions'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showTopUpDialog() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Top Up Wallet"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Enter Amount (\$)",
            prefixText: "\$ ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _generateTopUpQR(amount);
              }
            },
            child: const Text("Generate QR"),
          ),
        ],
      ),
    );
  }

  Future<void> _generateTopUpQR(double amount) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await PaymentService.generateTopUpQR(amount);
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result != null && result['success'] == true) {
        final bool? success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => TopUpQRPage(
              qrString: result['qrString'],
              amount: amount,
              md5: result['md5'],
            ),
          ),
        );

        if (success == true) {
          _fetchWalletData();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to generate QR code")),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWalletData,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWalletData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("My Wallet",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6600).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFFF6600), width: 1),
                          ),
                          child: const Text("Primary",
                              style: TextStyle(
                                  color: Color(0xFFFF6600),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Total Balance",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(
                            NumberFormat.currency(symbol: "\$")
                                .format(_balance),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionBtn(
                            Icons.add_rounded, "Top Up", _showTopUpDialog),
                        _buildActionBtn(
                            Icons.swap_horiz_rounded, "Transfer", () {}),
                        _buildActionBtn(
                            Icons.history_rounded, "History", () {}),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text("No recent transactions",
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Transactions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._transactions.map((tx) {
          final type = tx['type'].toString();
          final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
          final date = DateTime.parse(tx['createdAt']);
          final isDebit = type == 'purchase';

          return _transactionTile(
            tx['description'] ??
                (type == 'topup' ? "Wallet Top Up" : "Purchase"),
            "${isDebit ? '-' : '+'}\$${amount.toStringAsFixed(2)}",
            DateFormat('MMM dd, yyyy HH:mm').format(date),
            isDebit: isDebit,
          );
        }).toList(),
      ],
    );
  }

  Widget _transactionTile(String title, String amount, String date,
      {required bool isDebit}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isDebit
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        child: Icon(isDebit ? Icons.shopping_bag : Icons.add_card,
            color: isDebit ? Colors.red : Colors.green),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle: Text(date),
      trailing: Text(amount,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDebit ? Colors.red : Colors.green)),
    );
  }
}
