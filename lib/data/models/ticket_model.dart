import '../../domain/entities/ticket.dart';

class TicketModel extends Ticket {
  const TicketModel({
    required super.id,
    required super.eventId,
    required super.seatCategory,
    required super.quantity,
    required super.status,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        seatCategory: json['seat_category'] as String,
        quantity: json['quantity'] as int,
        status: TicketStatus.values.byName(json['status'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'seat_category': seatCategory,
        'quantity': quantity,
        'status': status.name,
      };
}
