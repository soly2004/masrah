import 'dart:math';

import '../payment_exceptions.dart';
import '../payment_processor.dart';

class FawryProcessor implements PaymentProcessor {
  @override
  String get name => 'Fawry';

  // Fawry has no stated per-transaction cap in payment_rules.md.
  @override
  double get maxLimit => double.infinity;

  @override
  List<PaymentField> get fields => const [
        PaymentField(key: 'mobile', label: 'Mobile number', hint: '01XXXXXXXXX', numeric: true),
        PaymentField(key: 'email', label: 'Email (for the receipt)', hint: 'name@example.com'),
      ];

  // Tiered flat fee: <500 -> 5, 500..1999 -> 10, 2000+ -> 25.
  @override
  double calculateFee(double base) {
    if (base < 500) return 5.00;
    if (base < 2000) return 10.00;
    return 25.00;
  }

  @override
  void validate(Map<String, String> details) {
    if (!RegExp(r'^01[0125]\d{8}$').hasMatch((details['mobile'] ?? '').trim())) {
      throw const PaymentValidationException(
          'Mobile number must be 11 digits and start with 010, 011, 012 or 015.');
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((details['email'] ?? '').trim())) {
      throw const PaymentValidationException('Please enter a valid email address.');
    }
  }

  @override
  Future<PaymentResult> process(double total, Map<String, String> details) async {
    await Future.delayed(const Duration(seconds: 1));
    final code = 100000000 + Random().nextInt(900000000); // 9 digits
    return PaymentResult(
      success: true,
      pending: true,
      reference: '$code',
      message: 'Pay ${total.toStringAsFixed(2)} EGP at any Fawry kiosk with code $code. '
          'The code expires in 24 hours, then your seat is released.',
    );
  }
}
