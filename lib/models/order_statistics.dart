class OrderStatistics {
  final int completedOrders;
  final int cancelledOrders;
  final int returnedOrders;
  final int totalDelivered;

  const OrderStatistics({
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.returnedOrders = 0,
    this.totalDelivered = 0,
  });

  OrderStatistics copyWith({
    int? completedOrders,
    int? cancelledOrders,
    int? returnedOrders,
    int? totalDelivered,
  }) {
    return OrderStatistics(
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      returnedOrders: returnedOrders ?? this.returnedOrders,
      totalDelivered: totalDelivered ?? this.totalDelivered,
    );
  }

  factory OrderStatistics.fromJson(Map<String, dynamic> json) {
    return OrderStatistics(
      completedOrders: json['completedOrders'] as int? ?? 0,
      cancelledOrders: json['cancelledOrders'] as int? ?? 0,
      returnedOrders: json['returnedOrders'] as int? ?? 0,
      totalDelivered: json['totalDelivered'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'returnedOrders': returnedOrders,
      'totalDelivered': totalDelivered,
    };
  }

  @override
  String toString() {
    return 'OrderStatistics(completed: $completedOrders, cancelled: $cancelledOrders, returned: $returnedOrders, total: $totalDelivered)';
  }
}

