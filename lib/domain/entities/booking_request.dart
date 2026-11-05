import '../../payment/payment_type.dart';
import 'event.dart';

/// Optional extras a customer can add to a booking (flat price per booking).
enum BookingExtra {
  vipParking('VIP parking', 100),
  merchandise('Merchandise pack', 200);

  final String label;
  final double priceEgp;
  const BookingExtra(this.label, this.priceEgp);
}

class BookingRequest {
  final Event event;
  final SeatCategory seat;
  final int quantity;
  final Set<BookingExtra> extras;
  final PaymentType paymentType;
  final Map<String, String> paymentDetails;

  const BookingRequest._({
    required this.event,
    required this.seat,
    required this.quantity,
    required this.extras,
    required this.paymentType,
    required this.paymentDetails,
  });
}

/// Builder pattern: event + seat are required, everything else is optional.
class BookingRequestBuilder {
  final Event _event;
  final SeatCategory _seat;
  int _quantity = 1;
  final Set<BookingExtra> _extras = {};
  PaymentType _paymentType = PaymentType.creditCard;
  Map<String, String> _details = {};

  BookingRequestBuilder(this._event, this._seat);

  BookingRequestBuilder withQuantity(int quantity) {
    _quantity = quantity;
    return this;
  }

  BookingRequestBuilder withExtra(BookingExtra extra) {
    _extras.add(extra);
    return this;
  }

  BookingRequestBuilder withPayment(PaymentType type, Map<String, String> details) {
    _paymentType = type;
    _details = details;
    return this;
  }

  BookingRequest build() {
    if (_quantity < 1) throw ArgumentError('Quantity must be at least 1');
    return BookingRequest._(
      event: _event,
      seat: _seat,
      quantity: _quantity,
      extras: Set.of(_extras),
      paymentType: _paymentType,
      paymentDetails: Map.of(_details),
    );
  }
}
