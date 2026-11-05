import '../payment_exceptions.dart';
import '../payment_processor.dart';

class DigitalWalletProcessor implements PaymentProcessor {
  static const meeza = 'Meeza Pay';
  static const apple = 'Apple Pay';

  @override
  String get name => 'Digital Wallet';

  @override
  double get maxLimit => 5000;

  @override
  List<PaymentField> get fields => const [
        PaymentField(key: 'wallet_type', label: 'Wallet', options: [meeza, apple]),
        PaymentField(key: 'wallet_id', label: 'Wallet ID / device token', hint: 'Meeza: 24 letters or digits'),
      ];

  // Flat 1.5% of the base price.
  @override
  double calculateFee(double base) => round2(base * 0.015);

  @override
  void validate(Map<String, String> details) {
    final id = (details['wallet_id'] ?? '').trim();
    if (id.isEmpty) {
      throw const PaymentValidationException('Wallet ID / device token is required.');
    }
    if (details['wallet_type'] == meeza && !RegExp(r'^[A-Za-z0-9]{24}$').hasMatch(id)) {
      throw const PaymentValidationException('A Meeza wallet ID must be alphanumeric and exactly 24 characters.');
    }
  }

  @override
  Future<PaymentResult> process(double total, Map<String, String> details) async {
    await Future.delayed(const Duration(seconds: 1));
    return PaymentResult(
      success: true,
      message: 'Wallet payment of ${total.toStringAsFixed(2)} EGP completed. Your tickets are issued.',
    );
  }
}
