import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/phone_launcher.dart';
import '../bloc/orders_bloc.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String formatCurrency(double amount) {
    return '${NumberFormat('#,###', 'fr_FR').format(amount)} CFA';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.statusPending;
      case 'CONFIRMED':
        return AppColors.statusConfirmed;
      case 'SHIPPED':
        return AppColors.statusShipped;
      case 'DELIVERED':
        return AppColors.statusDelivered;
      case 'CANCELLED':
        return AppColors.statusCancelled;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'En Attente';
      case 'CONFIRMED':
        return 'Confirmée';
      case 'SHIPPED':
        return 'En Livraison';
      case 'DELIVERED':
        return 'Livrée';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc()..add(LoadOrders()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Commandes Clients'),
        ),
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is OrdersLoaded) {
              final orders = state.orders;

              return Column(
                children: [
                  // Filter Chips Bar
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['ALL', 'PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED']
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(f == 'ALL' ? 'Toutes' : getStatusLabel(f)),
                                  selected: state.selectedFilter == f,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: state.selectedFilter == f ? Colors.white : AppColors.dark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      context.read<OrdersBloc>().add(LoadOrders(status: f));
                                    }
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // Orders List
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context.read<OrdersBloc>().add(LoadOrders(status: state.selectedFilter));
                      },
                      child: orders.isEmpty
                          ? const Center(child: Text('Aucune commande dans cette catégorie.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<OrdersBloc>(),
                                            child: OrderDetailScreen(order: order),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                order.orderNumber,
                                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: getStatusColor(order.status).withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  getStatusLabel(order.status),
                                                  style: TextStyle(
                                                    color: getStatusColor(order.status),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '${order.customerFirstName} ${order.customerLastName}',
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '📍 ${order.deliveryCity} - ${order.deliveryAddress}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                                          ),
                                          const Divider(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                formatCurrency(order.totalAmount),
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              // One-tap Quick Call Button
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.statusDelivered,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                onPressed: () {
                                                  PhoneLauncher.makeCall(order.customerPhone);
                                                },
                                                icon: const Icon(Icons.phone, size: 16),
                                                label: const Text('Appeler', style: TextStyle(fontSize: 12)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text('Erreur lors du chargement des commandes'));
          },
        ),
      ),
    );
  }
}
