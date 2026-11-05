import '../../payment/payment_method_factory.dart';
import '../../payment/payment_processor.dart';
import '../../payment/payment_type.dart';

/// Tells the UI which inputs a payment method needs, so the UI never branches on the method.
class GetPaymentFieldsUseCase {
  List<PaymentField> call(PaymentType type) => PaymentMethodFactory.create(type).fields;
}
