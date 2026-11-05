import '../../payment/payment_exceptions.dart';
import '../../payment/payment_method_factory.dart';
import '../../payment/payment_processor.dart';
import '../entities/booking_request.dart';
import '../entities/ticket.dart';
import '../repositories/event_repository.dart';
import 'calculate_ticket_price_use_case.dart';

class BookingResult {
  final Ticket ticket;
  final PriceBreakdown price;
  final PaymentResult payment;

  const BookingResult({required this.ticket, required this.price, required this.payment});

  String get headline {
    switch (ticket.status) {
      case TicketStatus.confirmed:
        return 'Booking confirmed';
      case TicketStatus.pending:
        return 'Booking pending';
      case TicketStatus.failed:
        return 'Payment failed';
      case TicketStatus.reserved:
        return 'Seat reserved';
    }
  }
}

class BookTicketUseCase {
  final EventRepository _repository;
  final CalculateTicketPriceUseCase _calculatePrice;

  BookTicketUseCase(this._repository, this._calculatePrice);

  Future<BookingResult> call(BookingRequest request) async {
    final processor = PaymentMethodFactory.create(request.paymentType);

    // 1. Validate and check limits before touching any seat.
    processor.validate(request.paymentDetails);
    final price = _calculatePrice(request);
    if (price.total > processor.maxLimit) {
      throw PaymentLimitExceededException(
        '${processor.name} allows up to ${processor.maxLimit.toStringAsFixed(0)} EGP per transaction. '
        'Your total is ${price.total.toStringAsFixed(2)} EGP.',
      );
    }

    // 2. Lock the seat BEFORE the payment processor is invoked.
    final ticket = await _repository.lockSeat(
      event: request.event,
      seat: request.seat,
      quantity: request.quantity,
    );

    // 3. Pay. Release the seat if anything goes wrong.
    try {
      final payment = await processor.process(price.total, request.paymentDetails);
      if (!payment.success) {
        await _repository.releaseSeat(ticket);
        return BookingResult(
          ticket: ticket.copyWith(status: TicketStatus.failed),
          price: price,
          payment: payment,
        );
      }
      final status = payment.pending ? TicketStatus.pending : TicketStatus.confirmed;
      return BookingResult(ticket: ticket.copyWith(status: status), price: price, payment: payment);
    } catch (_) {
      await _repository.releaseSeat(ticket);
      rethrow;
    }
  }
}
