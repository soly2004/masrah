import 'package:flutter/material.dart';

import '../../domain/entities/event.dart';
import '../../domain/use_cases/get_events_use_case.dart';
import '../widgets/event_card.dart';

class EventListPage extends StatefulWidget {
  final GetEventsUseCase getEvents;
  final Widget Function(Event event) checkoutBuilder;

  const EventListPage({super.key, required this.getEvents, required this.checkoutBuilder});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late Future<List<Event>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.getEvents();
  }

  void _openCheckout(Event event) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => widget.checkoutBuilder(event)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masrah - Live Events'), centerTitle: true),
      body: FutureBuilder<List<Event>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load events.'),
                  TextButton(
                    onPressed: () => setState(() => _future = widget.getEvents()),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }
          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) => EventCard(
              event: events[index],
              onBook: () => _openCheckout(events[index]),
            ),
          );
        },
      ),
    );
  }
}
