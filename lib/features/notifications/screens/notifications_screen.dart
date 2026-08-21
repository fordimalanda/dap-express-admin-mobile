import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/notifications_bloc.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all'; // 'all', 'unread', 'orders', 'alerts'

  void _simulateTestNotification(BuildContext context) {
    final random = Random();
    final orderNum = 1000 + random.nextInt(9000);
    final amounts = [24000, 39000, 58000, 85000];
    final amount = amounts[random.nextInt(amounts.length)];
    final cities = ['Brazzaville', 'Pointe-Noire', 'Dolisie'];
    final city = cities[random.nextInt(cities.length)];

    final newNotif = NotificationModel(
      id: 'sim-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Nouvelle commande reçue !',
      message: 'Commande #DAP-$orderNum pour $amount CFA ($city)',
      type: NotificationType.orderCreated,
      createdAt: DateTime.now(),
      isRead: false,
      route: '/orders',
    );

    context.read<NotificationsBloc>().add(AddNotification(newNotif));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nouvelle notification éphémère ajoutée !'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderCreated:
        return Icons.shopping_bag_outlined;
      case NotificationType.orderConfirmed:
        return Icons.verified_outlined;
      case NotificationType.orderDelivered:
        return Icons.check_circle_outline;
      case NotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case NotificationType.stockAlert:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderCreated:
        return AppColors.primary;
      case NotificationType.orderConfirmed:
        return Colors.blue;
      case NotificationType.orderDelivered:
        return AppColors.statusDelivered;
      case NotificationType.orderCancelled:
        return AppColors.statusCancelled;
      case NotificationType.stockAlert:
        return Colors.amber.shade800;
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.orderCreated:
        return 'Commande';
      case NotificationType.orderConfirmed:
        return 'Confirmée';
      case NotificationType.orderDelivered:
        return 'Livrée';
      case NotificationType.orderCancelled:
        return 'Annulée';
      case NotificationType.stockAlert:
        return 'Alerte Stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            final unread = state is NotificationsLoaded ? state.unreadCount : 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Notifications & Activités'),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Tout marquer comme lu',
            icon: const Icon(Icons.done_all),
            onPressed: () {
              context.read<NotificationsBloc>().add(MarkAllNotificationsAsRead());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les notifications ont été marquées comme lues'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Tout effacer',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {
              context.read<NotificationsBloc>().add(ClearAllNotifications());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is! NotificationsLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final allNotifs = state.notifications;
          final filteredList = allNotifs.where((n) {
            if (_selectedFilter == 'unread') return !n.isRead;
            if (_selectedFilter == 'orders') {
              return n.type == NotificationType.orderCreated ||
                  n.type == NotificationType.orderConfirmed ||
                  n.type == NotificationType.orderDelivered;
            }
            if (_selectedFilter == 'alerts') {
              return n.type == NotificationType.stockAlert || n.type == NotificationType.orderCancelled;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Ephemeral Information Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.primaryLight.withOpacity(0.4),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Notifications éphémères actives • Auto-nettoyage après 1 heure',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _simulateTestNotification(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 14, color: AppColors.primary),
                            SizedBox(width: 2),
                            Text(
                              'Tester',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Toutes (${allNotifs.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('unread', 'Non lues (${state.unreadCount})', isAlert: state.unreadCount > 0),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'orders',
                      'Commandes (${allNotifs.where((n) => n.type != NotificationType.stockAlert && n.type != NotificationType.orderCancelled).length})',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'alerts',
                      'Alertes (${allNotifs.where((n) => n.type == NotificationType.stockAlert || n.type == NotificationType.orderCancelled).length})',
                    ),
                  ],
                ),
              ),

              // List of Notifications
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: const Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucune notification récente',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Les alertes d\'actions récentes (moins de 1 heure) s\'afficheront ici.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => _simulateTestNotification(context),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Générer une alerte test'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notif = filteredList[index];
                          final color = _getTypeColor(notif.type);

                          return Dismissible(
                            key: Key(notif.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              context.read<NotificationsBloc>().add(DeleteNotification(notif.id));
                            },
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if (!notif.isRead) {
                                  context.read<NotificationsBloc>().add(MarkNotificationAsRead(notif.id));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: !notif.isRead
                                        ? AppColors.primary.withOpacity(0.35)
                                        : Colors.grey.shade200,
                                    width: !notif.isRead ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Type Icon Badge
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_getTypeIcon(notif.type), color: color, size: 22),
                                    ),
                                    const SizedBox(width: 12),

                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  _getTypeLabel(notif.type),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: color,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                notif.timeAgo,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                              if (!notif.isRead) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notif.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: !notif.isRead ? FontWeight.bold : FontWeight.w600,
                                              color: AppColors.dark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notif.message,
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.timer_outlined, size: 12, color: Colors.orange.shade800),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Expire dans ${notif.remainingMinutes} min',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange.shade800,
                                                ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () {
                                                  context
                                                      .read<NotificationsBloc>()
                                                      .add(DeleteNotification(notif.id));
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, {bool isAlert = false}) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Colors.white
              : (isAlert ? AppColors.primary : Colors.grey.shade700),
        ),
      ),
      selected: isSelected,
      selectedColor: isAlert && !isSelected ? AppColors.primaryLight : AppColors.dark,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isAlert ? AppColors.primary : Colors.grey.shade300),
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = key);
        }
      },
    );
  }
}
