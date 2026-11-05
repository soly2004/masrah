import '../entities/event.dart';
import '../entities/ticket.dart';

/// Contract only. The Data layer provides the implementation.
abstract class EventRepository {
  Future<List<Event>> getEvents();

  /// Locks the seats so nobody else can buy them while payment runs.
  Future<Ticket> lockSeat({
    required Event event,
    required SeatCategory seat,
    required int quantity,
  });

  Future<void> releaseSeat(Ticket ticket);
}
