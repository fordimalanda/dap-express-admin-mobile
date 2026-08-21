class OrderModel {
  final String id;
  final String orderNumber;
  final String customerFirstName;
  final String customerLastName;
  final String customerPhone;
  final String deliveryCity;
  final String deliveryAddress;
  final String? notes;
  final String status;
  final double totalAmount;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerFirstName,
    required this.customerLastName,
    required this.customerPhone,
    required this.deliveryCity,
    required this.deliveryAddress,
    this.notes,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerFirstName: json['customerFirstName'] ?? '',
      customerLastName: json['customerLastName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      deliveryCity: json['deliveryCity'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'PENDING',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  OrderModel copyWith({String? status}) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      customerFirstName: customerFirstName,
      customerLastName: customerLastName,
      customerPhone: customerPhone,
      deliveryCity: deliveryCity,
      deliveryAddress: deliveryAddress,
      notes: notes,
      status: status ?? this.status,
      totalAmount: totalAmount,
      createdAt: createdAt,
    );
  }
}
