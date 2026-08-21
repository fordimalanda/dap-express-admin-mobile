import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/notification_model.dart';

// EVENTS
abstract class NotificationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {}

class MarkNotificationAsRead extends NotificationsEvent {
  final String id;
  MarkNotificationAsRead(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {}

class DeleteNotification extends NotificationsEvent {
  final String id;
  DeleteNotification(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllNotifications extends NotificationsEvent {}

class AddNotification extends NotificationsEvent {
  final NotificationModel notification;
  AddNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

class AutoPurgeExpiredNotifications extends NotificationsEvent {}

// STATES
abstract class NotificationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

// BLOC
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  Timer? _purgeTimer;
  List<NotificationModel> _inMemoryList = [];

  NotificationsBloc() : super(NotificationsInitial()) {
    // Initialisation des données seed éphémères (moins d'1h)
    _initSeedData();

    // Nettoyage périodique toutes les 30 secondes pour purger les notifications > 1h
    _purgeTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(AutoPurgeExpiredNotifications());
    });

    on<LoadNotifications>((event, emit) {
      _purgeExpired();
      emit(_createLoadedState());
    });

    on<MarkNotificationAsRead>((event, emit) {
      _inMemoryList = _inMemoryList.map((n) {
        if (n.id == event.id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      _purgeExpired();
      emit(_createLoadedState());
    });

    on<MarkAllNotificationsAsRead>((event, emit) {
      _inMemoryList = _inMemoryList.map((n) => n.copyWith(isRead: true)).toList();
      _purgeExpired();
      emit(_createLoadedState());
    });

    on<DeleteNotification>((event, emit) {
      _inMemoryList.removeWhere((n) => n.id == event.id);
      _purgeExpired();
      emit(_createLoadedState());
    });

    on<ClearAllNotifications>((event, emit) {
      _inMemoryList.clear();
      emit(_createLoadedState());
    });

    on<AddNotification>((event, emit) {
      _inMemoryList.insert(0, event.notification);
      _purgeExpired();
      emit(_createLoadedState());
    });

    on<AutoPurgeExpiredNotifications>((event, emit) {
      _purgeExpired();
      emit(_createLoadedState());
    });
  }

  void _initSeedData() {
    final now = DateTime.now();
    _inMemoryList = [
      NotificationModel(
        id: 'flash-mob-1',
        title: 'Nouvelle commande reçue',
        message: 'Commande #DAP-7492 enregistrée pour 38 000 CFA (Brazzaville)',
        type: NotificationType.orderCreated,
        createdAt: now.subtract(const Duration(minutes: 4)),
        isRead: false,
        route: '/orders',
      ),
      NotificationModel(
        id: 'flash-mob-2',
        title: 'Livraison confirmée',
        message: 'Commande #DAP-7480 livrée avec succès au client (Pointe-Noire)',
        type: NotificationType.orderDelivered,
        createdAt: now.subtract(const Duration(minutes: 19)),
        isRead: false,
        route: '/orders',
      ),
      NotificationModel(
        id: 'flash-mob-3',
        title: 'Alerte Stock Critique',
        message: 'Stock faible pour "Écouteurs Sans Fil Pro" : seulement 3 unités restantes !',
        type: NotificationType.stockAlert,
        createdAt: now.subtract(const Duration(minutes: 36)),
        isRead: false,
        route: '/products',
      ),
      NotificationModel(
        id: 'flash-mob-4',
        title: 'Commande prête pour expédition',
        message: 'Commande #DAP-7475 confirmée par le client',
        type: NotificationType.orderConfirmed,
        createdAt: now.subtract(const Duration(minutes: 50)),
        isRead: true,
        route: '/orders',
      ),
    ];
  }

  void _purgeExpired() {
    _inMemoryList.removeWhere((n) => n.isExpired);
  }

  NotificationsLoaded _createLoadedState() {
    final validList = List<NotificationModel>.from(_inMemoryList)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final unread = validList.where((n) => !n.isRead).length;
    return NotificationsLoaded(
      notifications: validList,
      unreadCount: unread,
    );
  }

  @override
  Future<void> close() {
    _purgeTimer?.cancel();
    return super.close();
  }
}
