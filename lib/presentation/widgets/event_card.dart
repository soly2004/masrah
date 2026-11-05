import 'package:flutter/material.dart';

import '../../domain/entities/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onBook;

  const EventCard({super.key, required this.event, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.secondary),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: scheme.primary),
                const SizedBox(width: 4),
                Expanded(child: Text('${event.venue}, ${event.city}')),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: scheme.primary),
                const SizedBox(width: 4),
                Text(event.date.toIso8601String().substring(0, 10)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'From ${event.startingPrice.toStringAsFixed(0)} EGP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scheme.primary),
                ),
                FilledButton(onPressed: onBook, child: const Text('Book now')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
