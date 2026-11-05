/// Describes one input the payment form must show (so the UI never hardcodes
/// "if Fawry then show email").
class PaymentField {
  final String key;
  final String label;
  final String hint;
  final bool numeric;

  /// When not null the UI shows a dropdown with these choices.
  final List<String>? options;

  const PaymentField({
    required this.key,
    required this.label,
    this.hint = '',
    this.numeric = false,
    this.options,
  });
}

class PaymentResult {
  final bool success;

  /// true for asynchronous methods (Fawry) where the money is not collected yet.
  final bool pending;
  final String message;
  final String? reference;
  final String? redirectUrl;

  const PaymentResult({
    required this.success,
    required this.message,
    this.pending = false,
    this.reference,
    this.redirectUrl,
  });
}

/// Rounds to 2 decimals (piastres). No fractional piastres allowed.
double round2(double value) => (value * 100).round() / 100;

/// Product interface of the Factory Method.
abstract class PaymentProcessor {
  String get name;

  /// Maximum total per transaction in EGP.
  double get maxLimit;

  List<PaymentField> get fields;

  /// Gateway fee for the given base amount (before VAT).
  double calculateFee(double base);

  /// Throws a [PaymentValidationException] when [details] are not acceptable.
  void validate(Map<String, String> details);

  Future<PaymentResult> process(double total, Map<String, String> details);
}
