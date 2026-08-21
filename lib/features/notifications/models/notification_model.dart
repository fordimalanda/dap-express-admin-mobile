enum NotificationType {
  orderCreated,
  orderConfirmed,
  orderDelivered,
  orderCancelled,
  stockAlert,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? route;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.route,
    this.metadata,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? route,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      route: route ?? this.route,
      metadata: metadata ?? this.metadata,
    );
  }

  // Vérifie si la notification a dépassé la durée éphémère de 1 heure (60 minutes)
  bool get isExpired {
    return DateTime.now().difference(createdAt).inMinutes >= 60;
  }

  int get remainingMinutes {
    final elapsed = DateTime.now().difference(createdAt).inMinutes;
    final remaining = 60 - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes == 1) return "Il y a 1 min";
    return "Il y a ${diff.inMinutes} min";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'route': route,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.orderCreated,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      route: json['route'],
      metadata: json['metadata'],
    );
  }
}
