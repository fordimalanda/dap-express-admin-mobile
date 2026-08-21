import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/phone_launcher.dart';
import '../bloc/orders_bloc.dart';
import '../models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  String formatCurrency(double amount) {
    return '${NumberFormat('#,###', 'fr_FR').format(amount)} CFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande ${widget.order.orderNumber}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Selector Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statut de la commande', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _currentStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PENDING', child: Text('⏳ En Attente (À Confirmer)')),
                      DropdownMenuItem(value: 'CONFIRMED', child: Text('👍 Confirmée par Téléphone')),
                      DropdownMenuItem(value: 'SHIPPED', child: Text('🚚 En Cours de Livraison')),
                      DropdownMenuItem(value: 'DELIVERED', child: Text('✅ Livrée & Payée')),
                      DropdownMenuItem(value: 'CANCELLED', child: Text('❌ Commande Annulée')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _currentStatus = val);
                        context.read<OrdersBloc>().add(UpdateOrderStatusEvent(widget.order.id, val));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Statut mis à jour avec succès')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Client Contacts Card & Instant Action Buttons
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informations Client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.person, color: AppColors.primary)),
                    title: Text('${widget.order.customerFirstName} ${widget.order.customerLastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(widget.order.customerPhone),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDelivered),
                          onPressed: () => PhoneLauncher.makeCall(widget.order.customerPhone),
                          icon: const Icon(Icons.phone),
                          label: const Text('Appeler'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF25D366),
                            side: const BorderSide(color: Color(0xFF25D366)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => PhoneLauncher.openWhatsApp(widget.order.customerPhone),
                          icon: const Icon(Icons.chat),
                          label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Delivery Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lieu de Livraison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(height: 20),
                  Text('Ville : ${widget.order.deliveryCity}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Quartier / Repère : ${widget.order.deliveryAddress}'),
                  if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Notes : ${widget.order.notes}', style: TextStyle(color: Colors.amber.shade900, fontSize: 12)),
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total à Encaisser :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        formatCurrency(widget.order.totalAmount),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
