import 'payment_processor.dart';
import 'payment_type.dart';
import 'processors/credit_card_processor.dart';
import 'processors/digital_wallet_processor.dart';
import 'processors/fawry_processor.dart';
import 'processors/vodafone_cash_processor.dart';

/// Factory Method: the one place that knows which class handles which payment type.
class PaymentMethodFactory {
  const PaymentMethodFactory._();

  static PaymentProcessor create(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return CreditCardProcessor();
      case PaymentType.fawry:
        return FawryProcessor();
      case PaymentType.vodafoneCash:
        return VodafoneCashProcessor();
      case PaymentType.digitalWallet:
        return DigitalWalletProcessor();
    }
  }
}
