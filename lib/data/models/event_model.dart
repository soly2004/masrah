import '../../domain/entities/event.dart';

class SeatCategoryModel extends SeatCategory {
  const SeatCategoryModel({required super.name, required super.priceEgp});

  factory SeatCategoryModel.fromJson(Map<String, dynamic> json) => SeatCategoryModel(
        name: json['name'] as String,
        priceEgp: (json['price_egp'] as num).toDouble(),
      );
}

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.venue,
    required super.city,
    required super.date,
    required super.seatCategories,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        title: json['title'] as String,
        venue: json['venue'] as String,
        city: json['city'] as String,
        date: DateTime.parse(json['date'] as String),
        seatCategories: (json['seat_categories'] as List<dynamic>)
            .map((c) => SeatCategoryModel.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
