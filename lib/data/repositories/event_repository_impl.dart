import '../../domain/entities/event.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/ticket_model.dart';
import '../sources/local_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  final LocalDataSource _dataSource;
  final Map<String, TicketModel> _lockedTickets = {};

  EventRepositoryImpl(this._dataSource);

  @override
  Future<List<Event>> getEvents() => _dataSource.fetchEvents();

  @override
  Future<Ticket> lockSeat({
    required Event event,
    required SeatCategory seat,
    required int quantity,
  }) async {
    final ticket = TicketModel(
      id: 'TKT-${DateTime.now().millisecondsSinceEpoch}',
      eventId: event.id,
      seatCategory: seat.name,
      quantity: quantity,
      status: TicketStatus.reserved,
    );
    _lockedTickets[ticket.id] = ticket;
    return ticket;
  }

  @override
  Future<void> releaseSeat(Ticket ticket) async {
    _lockedTickets.remove(ticket.id);
  }
}
