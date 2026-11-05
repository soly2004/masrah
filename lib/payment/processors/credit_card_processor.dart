import 'dart:math';

import '../payment_exceptions.dart';
import '../payment_processor.dart';

class CreditCardProcessor implements PaymentProcessor {
  @override
  String get name => 'Credit Card';

  @override
  double get maxLimit => 20000;

  @override
  List<PaymentField> get fields => const [
        PaymentField(key: 'card_number', label: 'Card number', hint: '16 digits', numeric: true),
        PaymentField(key: 'expiry', label: 'Expiry date', hint: 'MM/YY'),
        PaymentField(key: 'cvv', label: 'CVV', hint: '3 digits', numeric: true),
      ];

  // 2.5% of the base price + 2.00 EGP per transaction.
  @override
  double calculateFee(double base) => round2(base * 0.025 + 2.00);

  @override
  void validate(Map<String, String> details) {
    final number = (details['card_number'] ?? '').replaceAll(' ', '');
    if (!RegExp(r'^\d{16}$').hasMatch(number) || !_passesLuhn(number)) {
      throw const PaymentValidationException('Card number must be 16 digits and pass the Luhn check.');
    }

    final expiry = (details['expiry'] ?? '').trim();
    final match = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$').firstMatch(expiry);
    if (match == null) {
      throw const PaymentValidationException('Expiry date must be in MM/YY format.');
    }
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    // A card is valid until the end of its expiry month.
    if (!DateTime.now().isBefore(DateTime(year, month + 1))) {
      throw const PaymentValidationException('This card has expired.');
    }

    if (!RegExp(r'^\d{3}$').hasMatch((details['cvv'] ?? '').trim())) {
      throw const PaymentValidationException('CVV must be exactly 3 digits.');
    }
  }

  @override
  Future<PaymentResult> process(double total, Map<String, String> details) async {
    await Future.delayed(const Duration(seconds: 1)); // simulated bank call
    final id = 100000 + Random().nextInt(900000);
    return PaymentResult(
      success: true,
      message: 'Payment of ${total.toStringAsFixed(2)} EGP captured. '
          'Complete the 3D Secure (OTP) step with your bank to finish.',
      reference: '$id',
      redirectUrl: 'https://acceptance.paymob.example/3ds/$id',
    );
  }

  bool _passesLuhn(String number) {
    var sum = 0;
    var doubleIt = false;
    for (var i = number.length - 1; i >= 0; i--) {
      var digit = int.parse(number[i]);
      if (doubleIt) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      doubleIt = !doubleIt;
    }
    return sum % 10 == 0;
  }
}
