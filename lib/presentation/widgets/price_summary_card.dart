import 'package:flutter/material.dart';

import '../../domain/use_cases/calculate_ticket_price_use_case.dart';

/// Only displays numbers that the domain layer already calculated.
class PriceSummaryCard extends StatelessWidget {
  final PriceBreakdown price;

  const PriceSummaryCard({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondary.withAlpha(90),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Order summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row('Tickets & extras', price.subtotal),
          _row('VAT (14%)', price.vat),
          _row('Payment fee', price.gatewayFee),
          const Divider(),
          _row('Total (EGP)', price.total, bold: true, color: scheme.primary),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontSize: bold ? 18 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value.toStringAsFixed(2), style: style),
        ],
      ),
    );
  }
}
