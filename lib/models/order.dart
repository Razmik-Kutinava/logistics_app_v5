enum OrderStatus { pending, confirmed, inTransit, delivered, cancelled }

enum DeliveryTime {
  urgent,     // Срочно (сейчас)
  oneHour,    // Через час
  twoHours,   // Через 2 часа
  threeHours, // Через 3 часа
  morning,    // Завтра утром
  afternoon,  // Завтра днем
  evening     // Завтра вечером
}

class Order {
  final String id;
  final String customerName;
  final String customerPhone;
  final String pickupAddress;
  final String deliveryAddress;
  final double weight;
  final String description;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? driverId;
  final String? driverName;
  final double? price;
  final String? trackingNumber;
  final String? completionPin;
  final DateTime? completedAt;

  // Новые поля по ТЗ CIO Logistics
  final String dimensions; // Габариты груза
  final double ridePrice; // Цена рейса
  final String? qrCode; // QR-код товара
  final double? latitude; // Координаты доставки
  final double? longitude;
  final int priority; // Приоритет заказа (для сортировки)
  final DeliveryTime deliveryTime; // Время доставки

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.weight,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.dimensions,
    required this.ridePrice,
    required this.deliveryTime,
    this.estimatedDelivery,
    this.driverId,
    this.driverName,
    this.price,
    this.trackingNumber,
    this.completionPin,
    this.completedAt,
    this.qrCode,
    this.latitude,
    this.longitude,
    this.priority = 0,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      pickupAddress: json['pickupAddress'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      weight: (json['weight'] as num).toDouble(),
      description: json['description'] as String,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dimensions: json['dimensions'] as String? ?? 'Не указаны',
      ridePrice: (json['ridePrice'] as num?)?.toDouble() ?? 0.0,
      deliveryTime: DeliveryTime.values.firstWhere(
        (e) => e.toString().split('.').last == json['deliveryTime'],
        orElse: () => DeliveryTime.afternoon,
      ),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      trackingNumber: json['trackingNumber'] as String?,
      completionPin: json['completionPin'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      qrCode: json['qrCode'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      priority: json['priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'weight': weight,
      'description': description,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'dimensions': dimensions,
      'ridePrice': ridePrice,
      'deliveryTime': deliveryTime.toString().split('.').last,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'driverId': driverId,
      'driverName': driverName,
      'price': price,
      'trackingNumber': trackingNumber,
      'completionPin': completionPin,
      'completedAt': completedAt?.toIso8601String(),
      'qrCode': qrCode,
      'latitude': latitude,
      'longitude': longitude,
      'priority': priority,
    };
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Ожидает подтверждения';
      case OrderStatus.confirmed:
        return 'Подтвержден';
      case OrderStatus.inTransit:
        return 'В пути';
      case OrderStatus.delivered:
        return 'Доставлен';
      case OrderStatus.cancelled:
        return 'Отменен';
    }
  }

  // Геттер для отображения цены рейса
  String get ridePriceFormatted {
    return '${ridePrice.toStringAsFixed(0)} драм';
  }

  // Геттер для отображения веса
  String get weightFormatted {
    return '${weight.toStringAsFixed(1)} кг';
  }

  // Геттер для отображения времени доставки
  String get deliveryTimeText {
    switch (deliveryTime) {
      case DeliveryTime.urgent:
        return 'Срочно (сейчас)';
      case DeliveryTime.oneHour:
        return 'Через час';
      case DeliveryTime.twoHours:
        return 'Через 2 часа';
      case DeliveryTime.threeHours:
        return 'Через 3 часа';
      case DeliveryTime.morning:
        return 'Завтра утром';
      case DeliveryTime.afternoon:
        return 'Завтра днем';
      case DeliveryTime.evening:
        return 'Завтра вечером';
    }
  }

  // Геттер для приоритета доставки (для сортировки)
  int get deliveryPriority {
    switch (deliveryTime) {
      case DeliveryTime.urgent:
        return 1;
      case DeliveryTime.oneHour:
        return 2;
      case DeliveryTime.twoHours:
        return 3;
      case DeliveryTime.threeHours:
        return 4;
      case DeliveryTime.morning:
        return 5;
      case DeliveryTime.afternoon:
        return 6;
      case DeliveryTime.evening:
        return 7;
    }
  }

  // Проверка, активен ли заказ
  bool get isActive {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  // Проверка, в работе ли заказ
  bool get isInProgress {
    return status == OrderStatus.inTransit;
  }

  // Проверка, завершен ли заказ
  bool get isCompleted {
    return status == OrderStatus.delivered || status == OrderStatus.cancelled;
  }

  // Геттер для координат
  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  Order copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? pickupAddress,
    String? deliveryAddress,
    double? weight,
    String? description,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    String? driverId,
    String? driverName,
    double? price,
    String? trackingNumber,
    String? completionPin,
    DateTime? completedAt,
    String? dimensions,
    double? ridePrice,
    String? qrCode,
    double? latitude,
    double? longitude,
    int? priority,
    DeliveryTime? deliveryTime,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      price: price ?? this.price,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      completionPin: completionPin ?? this.completionPin,
      completedAt: completedAt ?? this.completedAt,
      dimensions: dimensions ?? this.dimensions,
      ridePrice: ridePrice ?? this.ridePrice,
      qrCode: qrCode ?? this.qrCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      priority: priority ?? this.priority,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }
}
