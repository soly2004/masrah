import '../../data/repositories/event_repository_impl.dart';
import '../../data/sources/local_data_source.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/use_cases/book_ticket_use_case.dart';
import '../../domain/use_cases/calculate_ticket_price_use_case.dart';
import '../../domain/use_cases/get_events_use_case.dart';
import '../../domain/use_cases/get_payment_fields_use_case.dart';
import '../network/api_client.dart';

/// The ONLY place where objects are created and wired together.
/// Widgets receive ready-made use cases through their constructors.
class AppDependencies {
  late final GetEventsUseCase getEvents;
  late final CalculateTicketPriceUseCase calculatePrice;
  late final GetPaymentFieldsUseCase getPaymentFields;
  late final BookTicketUseCase bookTicket;

  AppDependencies() {
    final dataSource = LocalDataSource(ApiClient());
    final EventRepository repository = EventRepositoryImpl(dataSource);

    calculatePrice = CalculateTicketPriceUseCase();
    getEvents = GetEventsUseCase(repository);
    getPaymentFields = GetPaymentFieldsUseCase();
    bookTicket = BookTicketUseCase(repository, calculatePrice);
  }
}
