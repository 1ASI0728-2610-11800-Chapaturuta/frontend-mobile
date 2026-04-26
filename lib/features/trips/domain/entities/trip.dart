class Trip {
  final int id;
  final int routeId;
  final String routeName;
  final int userId;
  final DateTime date;
  final double price;
  final String status;

  const Trip({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.userId,
    required this.date,
    required this.price,
    required this.status,
  });
}
