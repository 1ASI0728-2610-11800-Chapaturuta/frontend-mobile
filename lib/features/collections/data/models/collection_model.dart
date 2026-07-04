/// Maps the backend `CollectionResource` (`/api/collections`).
class CollectionModel {
  final int id;
  final String name;
  final int fkIdUser;
  final DateTime createdAt;
  final int itemCount;

  const CollectionModel({
    required this.id,
    required this.name,
    required this.fkIdUser,
    required this.createdAt,
    required this.itemCount,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      fkIdUser: _int(json['fkIdUser']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      itemCount: _int(json['itemCount']),
    );
  }

  CollectionModel copyWith({String? name, int? itemCount}) => CollectionModel(
        id: id,
        name: name ?? this.name,
        fkIdUser: fkIdUser,
        createdAt: createdAt,
        itemCount: itemCount ?? this.itemCount,
      );

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

/// Maps the backend `CollectionItemResource` (a saved route inside a collection).
class CollectionItemModel {
  final int id;
  final int fkIdCollection;
  final int fkIdRoute;
  final DateTime addedAt;

  const CollectionItemModel({
    required this.id,
    required this.fkIdCollection,
    required this.fkIdRoute,
    required this.addedAt,
  });

  factory CollectionItemModel.fromJson(Map<String, dynamic> json) {
    return CollectionItemModel(
      id: CollectionModel._int(json['id']),
      fkIdCollection: CollectionModel._int(json['fkIdCollection']),
      fkIdRoute: CollectionModel._int(json['fkIdRoute']),
      addedAt: DateTime.tryParse(json['addedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
