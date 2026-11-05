import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEventsUseCase {
  final EventRepository _repository;

  GetEventsUseCase(this._repository);

  /// Returns events sorted by date (soonest first).
  Future<List<Event>> call() async {
    final events = await _repository.getEvents();
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }
}
