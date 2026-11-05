import '../../payment/payment_method_factory.dart';
import '../../payment/payment_processor.dart';
import '../entities/booking_request.dart';

class PriceBreakdown {
  final double subtotal; // seats + extras (the "base price")
  final double vat;
  final double gatewayFee;
  final double total;

  const PriceBreakdown({
    required this.subtotal,
    required this.vat,
    required this.gatewayFee,
    required this.total,
  });
}

/// total = base + 14% VAT on the base + gateway fee (see docs/payment_rules.md).
class CalculateTicketPriceUseCase {
  static const double vatRate = 0.14;

  PriceBreakdown call(BookingRequest request) {
    var base = request.seat.priceEgp * request.quantity;
    for (final extra in request.extras) {
      base += extra.priceEgp;
    }
    base = round2(base);

    final processor = PaymentMethodFactory.create(request.paymentType);
    final vat = round2(base * vatRate);
    final fee = processor.calculateFee(base);

    return PriceBreakdown(
      subtotal: base,
      vat: vat,
      gatewayFee: fee,
      total: round2(base + vat + fee),
    );
  }
}
