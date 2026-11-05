class SeatCategory {
  final String name;
  final double priceEgp;

  const SeatCategory({required this.name, required this.priceEgp});
}

class Event {
  final String id;
  final String title;
  final String venue;
  final String city;
  final DateTime date;
  final List<SeatCategory> seatCategories;

  const Event({
    required this.id,
    required this.title,
    required this.venue,
    required this.city,
    required this.date,
    required this.seatCategories,
  });

  /// Cheapest seat price, shown as "From X EGP".
  double get startingPrice {
    var lowest = seatCategories.first.priceEgp;
    for (final seat in seatCategories) {
      if (seat.priceEgp < lowest) lowest = seat.priceEgp;
    }
    return lowest;
  }
}
