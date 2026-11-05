# Masrah V2 - Clean Architecture refactor

Flutter app that lists live events and lets users book tickets with 4 payment methods.
All pricing and payment rules live in the Domain/payment code, **never in widgets**.
Rules source: [`docs/payment_rules.md`](docs/payment_rules.md).

## Run it
```bash
flutter create .      # only needed once if android/ ios/ folders are missing
flutter pub get
flutter run
```
(If `flutter create .` replaces `lib/main.dart`, copy the original back.)

Handy test data: card `4111 1111 1111 1111`, expiry in the future (e.g. `12/30`), CVV `123`;
Fawry/Vodafone mobile `01012345678`; Meeza ID = any 24 letters/digits.

## Architecture

```
lib/
  core/        di/ (wiring)  network/ (Singleton ApiClient)
  data/        models, repository implementation, local data source (reads the JSON)
  domain/      entities, repository interface, use cases   <- pure Dart, no Flutter
  payment/     PaymentType, Factory, one processor per method   <- pure Dart
  presentation/ pages + widgets  (only show data, never calculate it)
```

Dependencies point inward: `presentation -> domain <- data`. `domain` and `payment`
import no Flutter and nothing from `data`.

| Pattern | Where |
|---|---|
| Factory Method | `payment/payment_method_factory.dart` builds the right `PaymentProcessor` from a `PaymentType` |
| Singleton | `core/network/api_client.dart` (`ApiClient()` always returns the same instance) |
| Builder | `domain/entities/booking_request.dart` (`BookingRequestBuilder`, optional extras) |
| Dependency injection | `core/di/dependency_injection.dart` creates everything once; `main.dart` passes use cases into pages through constructors |

### Price formula
`total = base + 14% VAT on base + gateway fee`, rounded to 2 decimals.
`base = seat price x quantity + extras`. Fees and limits per method are inside each processor.

## How to add a new payment method (e.g. "InstaPay")
No presentation file changes. The checkout screen lists `PaymentType.values` and draws the
inputs from `processor.fields`.

1. **`lib/payment/payment_type.dart`** - add `instaPay('InstaPay')` to the enum.
2. **`lib/payment/processors/insta_pay_processor.dart`** - create a class that
   `implements PaymentProcessor` (name, maxLimit, fields, calculateFee, validate, process).
3. **`lib/payment/payment_method_factory.dart`** - add one `case PaymentType.instaPay:` returning `InstaPayProcessor()`.

Done. The dart compiler will point you at step 3 if you forget it (the `switch` is exhaustive).
