import '../payment_exceptions.dart';
import '../payment_processor.dart';

class VodafoneCashProcessor implements PaymentProcessor {
  /// The rules ask for a status check every 5 seconds.
  final Duration pollInterval;

  VodafoneCashProcessor({this.pollInterval = const Duration(seconds: 5)});

  @override
  String get name => 'Vodafone Cash';

  @override
  double get maxLimit => 10000;

  @override
  List<PaymentField> get fields => const [
        PaymentField(key: 'mobile', label: 'Vodafone number', hint: '010XXXXXXXX', numeric: true),
      ];

  // 1% of the base price, capped at 20 EGP.
  @override
  double calculateFee(double base) {
    final fee = round2(base * 0.01);
    return fee > 20.00 ? 20.00 : fee;
  }

  @override
  void validate(Map<String, String> details) {
    final mobile = (details['mobile'] ?? '').trim();
    if (!RegExp(r'^\d{11}$').hasMatch(mobile)) {
      throw const PaymentValidationException('Mobile number must be exactly 11 digits.');
    }
    if (!mobile.startsWith('010')) {
      throw const InvalidWalletProviderException(
          'Vodafone Cash numbers must start with 010 (not 011, 012 or 015).');
    }
  }

  @override
  Future<PaymentResult> process(double total, Map<String, String> details) async {
    // The user gets an SMS PIN prompt; we poll the backend until it settles.
    var status = 'pending';
    var attempt = 0;
    while (status == 'pending') {
      await Future.delayed(pollInterval);
      attempt++;
      status = await _fetchStatus(attempt);
    }

    if (status == 'success') {
      return PaymentResult(
        success: true,
        message: 'Vodafone Cash payment of ${total.toStringAsFixed(2)} EGP approved.',
      );
    }
    return const PaymentResult(success: false, message: 'Vodafone Cash payment failed.');
  }

  // Simulated backend: approves on the first poll.
  Future<String> _fetchStatus(int attempt) async => 'success';
}
