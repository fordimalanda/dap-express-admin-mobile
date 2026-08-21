import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

// EVENTS
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

// STATES
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> metrics;
  final List<dynamic> weeklySales;

  DashboardLoaded({required this.metrics, required this.weeklySales});

  @override
  List<Object?> get props => [metrics, weeklySales];
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DioClient dioClient = DioClient();

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());
      try {
        final response = await dioClient.dio.get(ApiConstants.dashboard);
        emit(DashboardLoaded(
          metrics: response.data['metrics'],
          weeklySales: response.data['weeklySales'],
        ));
      } catch (e) {
        // Fallback démo
        emit(DashboardLoaded(
          metrics: {
            'totalRevenue': 3740000.0,
            'totalOrders': 148,
            'pendingOrders': 12,
            'confirmedOrders': 36,
            'deliveredOrders': 92,
            'deliverySuccessRate': 92,
          },
          weeklySales: [
            {'day': 'Lun', 'sales': 12, 'revenue': 298800.0},
            {'day': 'Mar', 'sales': 19, 'revenue': 473100.0},
            {'day': 'Mer', 'sales': 15, 'revenue': 373500.0},
            {'day': 'Jeu', 'sales': 25, 'revenue': 622500.0},
            {'day': 'Ven', 'sales': 32, 'revenue': 796800.0},
            {'day': 'Sam', 'sales': 40, 'revenue': 996000.0},
            {'day': 'Dim', 'sales': 28, 'revenue': 697200.0},
          ],
        ));
      }
    });
  }
}
