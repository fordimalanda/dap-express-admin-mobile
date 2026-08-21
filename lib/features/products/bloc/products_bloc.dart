import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

// EVENTS
abstract class ProductsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {}

// STATES
abstract class ProductsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}
class ProductsLoading extends ProductsState {}
class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}
class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final DioClient dioClient = DioClient();

  ProductsBloc() : super(ProductsInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductsLoading());
      try {
        final response = await dioClient.dio.get(ApiConstants.products);
        final List list = response.data;
        final products = list.map((item) => ProductModel.fromJson(item)).toList();
        emit(ProductsLoaded(products));
      } catch (e) {
        // Fallback démo
        emit(ProductsLoaded([
          ProductModel(
            id: 'prod-1',
            name: 'Pack Écouteurs Pro Max Sans Fil',
            slug: 'pack-ecouteurs-pro-max',
            description: 'Réduction active du bruit & autonomie longue durée',
            price: 24900,
            originalPrice: 45000,
            images: ['https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800&q=80'],
            stock: 45,
            isAvailable: true,
          ),
        ]));
      }
    });
  }
}
