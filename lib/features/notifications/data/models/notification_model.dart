/// Maps the backend `NotificationResource` (`/api/notifications`).
class NotificationModel {
  final int id;
  final int fkIdUser;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.fkIdUser,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _int(json['id']),
      fkIdUser: _int(json['fkIdUser']),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'Info').toString(),
      isRead: json['isRead'] is bool ? json['isRead'] : false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        fkIdUser: fkIdUser,
        title: title,
        message: message,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
