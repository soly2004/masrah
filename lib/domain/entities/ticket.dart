enum TicketStatus { reserved, pending, confirmed, failed }

class Ticket {
  final String id;
  final String eventId;
  final String seatCategory;
  final int quantity;
  final TicketStatus status;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.seatCategory,
    required this.quantity,
    required this.status,
  });

  Ticket copyWith({TicketStatus? status}) => Ticket(
        id: id,
        eventId: eventId,
        seatCategory: seatCategory,
        quantity: quantity,
        status: status ?? this.status,
      );
}
