/// Every payment method Masrah supports.
/// To add a new one: add a value here, write a processor, add one case in the factory.
enum PaymentType {
  creditCard('Credit Card'),
  fawry('Fawry'),
  vodafoneCash('Vodafone Cash'),
  digitalWallet('Digital Wallet');

  final String label;
  const PaymentType(this.label);
}
