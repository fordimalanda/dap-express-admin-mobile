import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/order_model.dart';

// EVENTS
abstract class OrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  final String? status;
  LoadOrders({this.status});

  @override
  List<Object?> get props => [status];
}

class UpdateOrderStatusEvent extends OrdersEvent {
  final String orderId;
  final String newStatus;
  UpdateOrderStatusEvent(this.orderId, this.newStatus);

  @override
  List<Object?> get props => [orderId, newStatus];
}

// STATES
abstract class OrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}
class OrdersLoading extends OrdersState {}
class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final String selectedFilter;

  OrdersLoaded({required this.orders, this.selectedFilter = 'ALL'});

  @override
  List<Object?> get props => [orders, selectedFilter];
}
class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final DioClient dioClient = DioClient();

  OrdersBloc() : super(OrdersInitial()) {
    on<LoadOrders>((event, emit) async {
      emit(OrdersLoading());
      try {
        final queryParams = event.status != null && event.status != 'ALL' ? {'status': event.status} : null;
        final response = await dioClient.dio.get(ApiConstants.orders, queryParameters: queryParams);
        final List list = response.data;
        final orders = list.map((item) => OrderModel.fromJson(item)).toList();
        emit(OrdersLoaded(orders: orders, selectedFilter: event.status ?? 'ALL'));
      } catch (e) {
        // Fallback démo
        final sampleOrders = [
          OrderModel(
            id: 'ord-1',
            orderNumber: 'DAP-250220-4821',
            customerFirstName: 'Yves',
            customerLastName: 'Kouamé',
            customerPhone: '+2250708091011',
            deliveryCity: 'Abidjan',
            deliveryAddress: 'Cocody Riviera 3, Villa 4',
            notes: 'Appeler avant de venir',
            status: 'PENDING',
            totalAmount: 24900,
            createdAt: DateTime.now().toIso8601String(),
          ),
          OrderModel(
            id: 'ord-2',
            orderNumber: 'DAP-250220-3190',
            customerFirstName: 'Amadou',
            customerLastName: 'Diallo',
            customerPhone: '+221776543210',
            deliveryCity: 'Dakar',
            deliveryAddress: 'Plateau, Rue Carnot',
            status: 'CONFIRMED',
            totalAmount: 49800,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          ),
        ];
        emit(OrdersLoaded(orders: sampleOrders, selectedFilter: event.status ?? 'ALL'));
      }
    });

    on<UpdateOrderStatusEvent>((event, emit) async {
      if (state is OrdersLoaded) {
        final currentOrders = (state as OrdersLoaded).orders;
        try {
          await dioClient.dio.patch(
            '${ApiConstants.orders}/${event.orderId}/status',
            data: {'status': event.newStatus},
          );
        } catch (e) {
          // Log fallback
        }
        final updated = currentOrders.map((o) {
          return o.id == event.orderId ? o.copyWith(status: event.newStatus) : o;
        }).toList();
        emit(OrdersLoaded(orders: updated, selectedFilter: (state as OrdersLoaded).selectedFilter));
      }
    });
  }
}
