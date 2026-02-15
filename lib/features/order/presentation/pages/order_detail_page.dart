import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:app1/models/order.dart';
import 'package:app1/features/order/presentation/widgets/payment_status_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  final bool isDark;

  const OrderDetailPage({
    super.key,
    required this.order,
    required this.isDark,
  });

  static const Color lazadaOrange = Color(0xFFFF6600);
  static const Color accentColor = Color(0xFF00ADED);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F8FA);
    final cardColor = isDark ? const Color(0xFF1E2026) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final labelColor =
        isDark ? Colors.white54 : Colors.grey[600] ?? Colors.grey;
    final dividerColor =
        isDark ? Colors.white10 : Colors.grey[200] ?? Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Order Details",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            _buildStatusSection(context, cardColor, textColor, labelColor),
            const SizedBox(height: 16),

            // Timeline Section
            _buildTimelineSection(
                cardColor, textColor, labelColor, dividerColor),
            const SizedBox(height: 16),

            // Order Items Section
            _buildItemsSection(cardColor, textColor, labelColor, dividerColor),
            const SizedBox(height: 16),

            // Delivery Address
            _buildAddressSection(cardColor, textColor, labelColor),
            const SizedBox(height: 16),

            // Payment Summary
            _buildSummarySection(
                cardColor, textColor, labelColor, dividerColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, Color cardColor,
      Color textColor, Color labelColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${order.orderNumber ?? 'N/A'}",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(order.createdAt),
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.payment_rounded, size: 16, color: labelColor),
              const SizedBox(width: 8),
              Text(
                "Payment Status:",
                style: TextStyle(color: labelColor, fontSize: 10),
              ),
              const Spacer(),
              PaymentStatusBadge(status: order.paymentStatus ?? 'pending'),
            ],
          ),
          if (order.trackingNumber != null &&
              order.trackingNumber!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.local_shipping_rounded, size: 16, color: labelColor),
                const SizedBox(width: 8),
                Text(
                  "Tracking Code:",
                  style: TextStyle(color: labelColor, fontSize: 10),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: order.trackingNumber!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Tracking number copied to clipboard"),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: lazadaOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.trackingNumber!,
                          style: const TextStyle(
                            color: lazadaOrange,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy, size: 10, color: lazadaOrange),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildTimelineSection(
      Color cardColor, Color textColor, Color labelColor, Color dividerColor) {
    final status = order.status?.toLowerCase() ?? 'pending';

    // Define steps
    final steps = [
      {'title': 'Order Placed', 'status': 'pending'},
      {'title': 'Processing', 'status': 'processing'},
      {'title': 'Shipped', 'status': 'shipped'},
      {'title': 'Delivered', 'status': 'delivered'},
    ];

    int currentStep = 0;
    if (status == 'processing') currentStep = 1;
    if (status == 'shipped') currentStep = 2;
    if (status == 'delivered') currentStep = 3;
    if (status == 'cancelled') currentStep = -1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Status",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(steps.length, (index) {
            bool isLast = index == steps.length - 1;
            bool isCompleted = index <= currentStep;
            bool isCurrent = index == currentStep;

            Color stepColor =
                isCompleted ? lazadaOrange : labelColor.withOpacity(0.3);
            if (status == 'cancelled') stepColor = Colors.red;

            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? stepColor.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: stepColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(Icons.check, size: 14, color: stepColor)
                              : Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: stepColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: stepColor.withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index]['title']!,
                          style: TextStyle(
                            color: isCompleted ? textColor : labelColor,
                            fontWeight:
                                isCompleted ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isCurrent)
                          Text(
                            "Your order is currently ${steps[index]['title']!.toLowerCase()}",
                            style: TextStyle(color: labelColor, fontSize: 12),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (order.trackingNumber != null &&
              order.trackingNumber!.isNotEmpty) ...[
            Divider(color: dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 18, color: labelColor),
                const SizedBox(width: 8),
                Text(
                  "Tracking Number:",
                  style: TextStyle(color: labelColor, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  order.trackingNumber!,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildItemsSection(
      Color cardColor, Color textColor, Color labelColor, Color dividerColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Items",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          ...order.items.map((item) {
            final product = item.product;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          image: product?.image != null &&
                                  product!.image.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(product.image),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: product?.image == null || product!.image.isEmpty
                            ? Icon(Icons.image_not_supported,
                                size: 24, color: labelColor)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?.name ?? "Product Name",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (item.productVariant != null)
                              Wrap(
                                spacing: 8,
                                children: item.productVariant!.attributeOptions
                                    .map((opt) {
                                  return Text(
                                    "${opt.attributeName}: ${opt.value}",
                                    style: TextStyle(
                                        color: labelColor, fontSize: 11),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              "Qty: ${item.quantity} x \$${item.price.toStringAsFixed(2)}",
                              style: TextStyle(color: labelColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.items.indexOf(item) != order.items.length - 1)
                  Divider(height: 1, color: dividerColor, indent: 102),
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAddressSection(
      Color cardColor, Color textColor, Color labelColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: lazadaOrange),
              const SizedBox(width: 8),
              Text(
                "Delivery Address",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.shippingAddress ?? "No address provided",
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: labelColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.note_alt_outlined, size: 16, color: labelColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.notes!,
                      style: TextStyle(color: labelColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSummarySection(
      Color cardColor, Color textColor, Color labelColor, Color dividerColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
              "Subtotal",
              "\$${order.subtotal?.toStringAsFixed(2) ?? '0.00'}",
              labelColor,
              textColor),
          const SizedBox(height: 8),
          _buildSummaryRow(
              "Shipping",
              "\$${order.shipping?.toStringAsFixed(2) ?? '0.00'}",
              labelColor,
              textColor),
          if (order.discount != null && order.discount! > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
                "Discount",
                "-\$${order.discount?.toStringAsFixed(2)}",
                Colors.green,
                Colors.green),
          ],
          const SizedBox(height: 12),
          Divider(color: dividerColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                "\$${order.totalPrice?.toStringAsFixed(2) ?? '0.00'}",
                style: TextStyle(
                  color: lazadaOrange,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSummaryRow(
      String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: labelColor, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
