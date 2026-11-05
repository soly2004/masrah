import 'package:flutter/material.dart';

import 'core/di/dependency_injection.dart';
import 'presentation/pages/checkout_page.dart';
import 'presentation/pages/event_list_page.dart';

const Color _rose = Color(0xFFE0457B);
const Color _lightPurple = Color(0xFFD9C8FF);
const Color _background = Color(0xFFF7F2FF);
const Color _ink = Color(0xFF3B1D4F);

void main() {
  runApp(MasrahApp(di: AppDependencies()));
}

class MasrahApp extends StatelessWidget {
  final AppDependencies di;

  const MasrahApp({super.key, required this.di});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masrah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _rose).copyWith(
          primary: _rose,
          onPrimary: Colors.white,
          secondary: _lightPurple,
          onSecondary: _ink,
          secondaryContainer: _lightPurple,
          onSecondaryContainer: _ink,
        ),
        scaffoldBackgroundColor: _background,
        appBarTheme: const AppBarTheme(
          backgroundColor: _rose,
          foregroundColor: Colors.white,
        ),
      ),
      home: EventListPage(
        getEvents: di.getEvents,
        checkoutBuilder: (event) => CheckoutPage(
          event: event,
          calculatePrice: di.calculatePrice,
          getPaymentFields: di.getPaymentFields,
          bookTicket: di.bookTicket,
        ),
      ),
    );
  }
}
