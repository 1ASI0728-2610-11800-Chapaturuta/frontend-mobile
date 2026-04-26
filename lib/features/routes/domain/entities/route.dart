
class TransportRoute {
  final int id;
  final String name;
  final double price;
  final String duration;
  final String distance;
  final String state;
  final String? polylineRoute;
  final int driverId;
  
  // Estos campos los derivamos del name o los dejamos opcionales
  final String? originAddress;
  final String? destinationAddress;

  TransportRoute({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.distance,
    required this.state,
    this.polylineRoute,
    required this.driverId,
    this.originAddress,
    this.destinationAddress,
  });

  // Método helper para obtener nombre del origen (parseamos el name)
  String get origin {
    if (originAddress != null) return originAddress!;
    final parts = name.split('-');
    return parts.isNotEmpty ? parts[0].trim() : 'Origen';
  }

  // Método helper para obtener nombre del destino
  String get destination {
    if (destinationAddress != null) return destinationAddress!;
    final parts = name.split('-');
    return parts.length > 1 ? parts[1].trim() : 'Destino';
  }
}