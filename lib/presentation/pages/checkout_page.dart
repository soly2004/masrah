import 'package:flutter/material.dart';

import '../../domain/entities/booking_request.dart';
import '../../domain/entities/event.dart';
import '../../domain/use_cases/book_ticket_use_case.dart';
import '../../domain/use_cases/calculate_ticket_price_use_case.dart';
import '../../domain/use_cases/get_payment_fields_use_case.dart';
import '../../payment/payment_exceptions.dart';
import '../../payment/payment_type.dart';
import '../widgets/price_summary_card.dart';

/// Pure UI: it collects the user's choices and shows what the use cases return.
class CheckoutPage extends StatefulWidget {
  final Event event;
  final CalculateTicketPriceUseCase calculatePrice;
  final GetPaymentFieldsUseCase getPaymentFields;
  final BookTicketUseCase bookTicket;

  const CheckoutPage({
    super.key,
    required this.event,
    required this.calculatePrice,
    required this.getPaymentFields,
    required this.bookTicket,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late SeatCategory _seat = widget.event.seatCategories.first;
  int _quantity = 1;
  final Set<BookingExtra> _extras = {};
  PaymentType _paymentType = PaymentType.creditCard;
  Map<String, String> _details = {};
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _details = _defaultDetails(_paymentType);
  }

  Map<String, String> _defaultDetails(PaymentType type) {
    final details = <String, String>{};
    for (final field in widget.getPaymentFields(type)) {
      final options = field.options;
      if (options != null) details[field.key] = options.first;
    }
    return details;
  }

  BookingRequest _buildRequest() {
    final builder = BookingRequestBuilder(widget.event, _seat)
        .withQuantity(_quantity)
        .withPayment(_paymentType, _details);
    for (final extra in _extras) {
      builder.withExtra(extra);
    }
    return builder.build();
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    try {
      final result = await widget.bookTicket(_buildRequest());
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(result.headline),
          content: Text('${result.payment.message}\n\nTicket: ${result.ticket.id}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Done')),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on PaymentException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    if (_processing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing your payment securely...'),
            ],
          ),
        ),
      );
    }

    final price = widget.calculatePrice(_buildRequest());
    final fields = widget.getPaymentFields(_paymentType);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.event.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

          _title('Seat category'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final seat in widget.event.seatCategories)
                ChoiceChip(
                  label: Text('${seat.name} · ${seat.priceEgp.toStringAsFixed(0)} EGP'),
                  selected: seat == _seat,
                  onSelected: (_) => setState(() => _seat = seat),
                ),
            ],
          ),

          _title('Quantity'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 32),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 32),
                onPressed: _quantity < 10 ? () => setState(() => _quantity++) : null,
              ),
            ],
          ),

          _title('Extras (optional)'),
          for (final extra in BookingExtra.values)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(extra.label),
              subtitle: Text('+${extra.priceEgp.toStringAsFixed(0)} EGP'),
              value: _extras.contains(extra),
              onChanged: (checked) => setState(() {
                if (checked == true) {
                  _extras.add(extra);
                } else {
                  _extras.remove(extra);
                }
              }),
            ),

          _title('Payment method'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in PaymentType.values)
                ChoiceChip(
                  label: Text(type.label),
                  selected: type == _paymentType,
                  onSelected: (_) => setState(() {
                    _paymentType = type;
                    _details = _defaultDetails(type);
                  }),
                ),
            ],
          ),
          for (final field in fields)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: field.options == null
                  ? TextField(
                      key: ValueKey('${_paymentType.name}-${field.key}'),
                      keyboardType: field.numeric ? TextInputType.number : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: field.label,
                        hintText: field.hint,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => _details[field.key] = value,
                    )
                  : DropdownButtonFormField<String>(
                      key: ValueKey('${_paymentType.name}-${field.key}'),
                      value: _details[field.key],
                      decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
                      items: [
                        for (final option in field.options!)
                          DropdownMenuItem(value: option, child: Text(option)),
                      ],
                      onChanged: (value) => setState(() => _details[field.key] = value ?? ''),
                    ),
            ),

          const SizedBox(height: 24),
          PriceSummaryCard(price: price),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _pay,
              child: Text('Pay ${price.total.toStringAsFixed(2)} EGP'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
