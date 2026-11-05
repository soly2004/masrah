/// Base class so the UI can catch every payment problem with one `on` clause.
class PaymentException implements Exception {
  final String message;
  const PaymentException(this.message);

  @override
  String toString() => message;
}

class PaymentValidationException extends PaymentException {
  const PaymentValidationException(super.message);
}

/// Thrown when a Vodafone Cash number does not start with 010.
class InvalidWalletProviderException extends PaymentValidationException {
  const InvalidWalletProviderException(super.message);
}

class PaymentLimitExceededException extends PaymentException {
  const PaymentLimitExceededException(super.message);
}
