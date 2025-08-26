import 'package:flutter/foundation.dart';
import 'package:logistics_app/models/order.dart';
import 'package:logistics_app/models/order_statistics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  OrderStatistics _statistics = const OrderStatistics();

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderStatistics get statistics => _statistics;

  List<Order> get pendingOrders =>
      _orders.where((order) => order.status == OrderStatus.pending).toList();

  List<Order> get activeOrders => _orders
      .where(
        (order) =>
            order.status == OrderStatus.confirmed ||
            order.status == OrderStatus.inTransit ||
            order.status == OrderStatus.returned,
      )
      .toList();

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Загружаем статистику
      await _loadStatistics();

      // Имитация загрузки данных
      await Future.delayed(const Duration(seconds: 1));

      _orders = [
        Order(
          id: '1',
          customerName: 'Арам Сарксян',
          customerPhone: '+37491123456',
          pickupAddress: 'ул. Абовяна, 15, Ереван',
          deliveryAddress: 'ул. Северная, 25, Ереван',
          weight: 5.5,
          description: 'Электроника',
          status: OrderStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          price: 15000.0,
          dimensions: '40x30x20 см',
          ridePrice: 15000.0,
          trackingNumber: 'CIO001',
          deliveryTime: DeliveryTime.urgent,
          latitude: 40.1776,
          longitude: 44.5126,
          priority: 1,
        ),
        Order(
          id: '2',
          customerName: 'Мария Хачатрян',
          customerPhone: '+37491234567',
          pickupAddress: 'пр. Багратиона, 10, Ереван',
          deliveryAddress: 'ул. Пушкина, 35, Ереван',
          weight: 2.0,
          description: 'Документы',
          status: OrderStatus.inTransit,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          estimatedDelivery: DateTime.now().add(const Duration(hours: 1)),
          driverId: 'driver1',
          driverName: 'Арам Григорян',
          price: 8000.0,
          dimensions: '30x20x5 см',
          ridePrice: 8000.0,
          trackingNumber: 'CIO002',
          deliveryTime: DeliveryTime.oneHour,
          latitude: 40.1911,
          longitude: 44.4991,
          priority: 2,
        ),
        Order(
          id: '3',
          customerName: 'Петрос Аветисян',
          customerPhone: '+37491345678',
          pickupAddress: 'ул. Арами, 25, Ереван',
          deliveryAddress: 'ул. Сарьяна, 40, Ереван',
          weight: 10.0,
          description: 'Мебель',
          status: OrderStatus.delivered,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          estimatedDelivery: DateTime.now().subtract(const Duration(hours: 2)),
          driverId: 'driver1',
          driverName: 'Арам Григорян',
          price: 25000.0,
          dimensions: '120x80x40 см',
          ridePrice: 25000.0,
          trackingNumber: 'CIO003',
          deliveryTime: DeliveryTime.morning,
          completionPin: '123456',
          completedAt: DateTime.now().subtract(const Duration(hours: 2)),
          latitude: 40.1872,
          longitude: 44.5152,
          priority: 3,
        ),
        Order(
          id: '4',
          customerName: 'Анна Карапетян',
          customerPhone: '+37491456789',
          pickupAddress: 'ул. Комитаса, 5, Ереван',
          deliveryAddress: 'ул. Московская, 18, Ереван',
          weight: 3.2,
          description: 'Продукты питания',
          status: OrderStatus.confirmed,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          estimatedDelivery: DateTime.now().add(const Duration(hours: 2)),
          price: 12000.0,
          dimensions: '25x25x15 см',
          ridePrice: 12000.0,
          trackingNumber: 'CIO004',
          deliveryTime: DeliveryTime.twoHours,
          latitude: 40.2038,
          longitude: 44.5152,
          priority: 4,
        ),
        Order(
          id: '5',
          customerName: 'Давид Манукян',
          customerPhone: '+37491567890',
          pickupAddress: 'ул. Маштоца, 12, Ереван',
          deliveryAddress: 'ул. Арцахская, 8, Ереван',
          weight: 1.5,
          description: 'Лекарства',
          status: OrderStatus.cancelled,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          price: 5000.0,
          dimensions: '15x10x8 см',
          ridePrice: 5000.0,
          trackingNumber: 'CIO005',
          deliveryTime: DeliveryTime.afternoon,
          latitude: 40.1836,
          longitude: 44.5147,
          priority: 5,
        ),
        // Тестовый заказ на возврат
        Order(
          id: '6',
          customerName: 'Карен Аветисян',
          customerPhone: '+37491999888',
          pickupAddress: 'ул. Арам Хачатуряна, 30, Ереван',
          deliveryAddress: 'ул. Саят-Нова, 15, Ереван',
          weight: 2.0,
          description: 'Возврат товара',
          status: OrderStatus.returned,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isReturn: true,
          returnRequestedAt:
              DateTime.now().subtract(const Duration(minutes: 30)),
          returnReason: 'Клиент передумал',
          price: 8000.0,
          dimensions: '25x20x15 см',
          ridePrice: 8000.0,
          trackingNumber: 'CIO006',
          deliveryTime: DeliveryTime.urgent,
          latitude: 40.1792,
          longitude: 44.4991,
          priority: 0, // Высший приоритет для возвратов
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки заказов';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> takeOrder(String orderId) async {
    debugPrint('🔄 Взятие заказа $orderId в работу');

    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: OrderStatus.inTransit,
        driverId: 'current_driver',
        driverName: 'Арам Григорян',
      );

      debugPrint('✅ Заказ $orderId взят в работу');
      notifyListeners();
    } else {
      debugPrint('❌ Заказ $orderId не найден');
    }
  }

  Future<void> completeOrder(String orderId, String pin) async {
    debugPrint('🔄 Завершение заказа $orderId с PIN: $pin');

    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      // В реальном приложении здесь будет проверка PIN через API
      // Для демо принимаем любой 6-значный PIN
      if (pin.length == 6) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: OrderStatus.delivered,
          completionPin: pin,
          completedAt: DateTime.now(),
        );

        debugPrint('✅ Заказ $orderId успешно завершен');
        await _incrementCompleted(); // Увеличиваем счетчик завершенных
        notifyListeners();
      } else {
        debugPrint('❌ Неверный PIN для заказа $orderId');
      }
    } else {
      debugPrint('❌ Заказ $orderId не найден');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    debugPrint('🔄 Обновление статуса заказа $orderId на $status');

    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final oldStatus = _orders[orderIndex].status;
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: status,
        driverId: status == OrderStatus.inTransit
            ? 'current_driver'
            : _orders[orderIndex].driverId,
        driverName: status == OrderStatus.inTransit
            ? 'Арам Григорян'
            : _orders[orderIndex].driverName,
        completedAt: status == OrderStatus.delivered ? DateTime.now() : null,
      );

      // Обновляем статистику в зависимости от нового статуса
      if (status == OrderStatus.delivered &&
          oldStatus != OrderStatus.delivered) {
        await _incrementCompleted();
      } else if (status == OrderStatus.cancelled &&
          oldStatus != OrderStatus.cancelled) {
        await _incrementCancelled();
      }

      debugPrint(
          '✅ Статус заказа $orderId изменен с $oldStatus на ${_orders[orderIndex].status}');
      notifyListeners();
    } else {
      debugPrint('❌ Заказ $orderId не найден');
    }
  }

  Future<void> addOrder(Order order) async {
    _orders.add(order);
    notifyListeners();
  }

  // Обновить трек-номер заказа
  Future<void> updateTrackingNumber(
      String orderId, String trackingNumber) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] =
          _orders[orderIndex].copyWith(trackingNumber: trackingNumber);
      notifyListeners();
      debugPrint('📦 Трекер заказа $orderId обновлен: $trackingNumber');
    }
  }

  // Обновить время доставки заказа
  Future<void> updateDeliveryTime(
      String orderId, DeliveryTime deliveryTime) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] =
          _orders[orderIndex].copyWith(deliveryTime: deliveryTime);
      notifyListeners();
      debugPrint(
          '⏰ Время доставки заказа $orderId обновлено: ${_orders[orderIndex].deliveryTimeText}');
    }
  }

  // Вернуть заказ
  Future<void> returnOrder(String orderId, String reason) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: OrderStatus.cancelled,
        completedAt: DateTime.now(),
      );

      await _incrementReturned(); // Увеличиваем счетчик возвратов
      debugPrint('🔄 Заказ $orderId возвращен: $reason');
      notifyListeners();
    }
  }

  // Добавить заказ через QR-код
  Future<void> addOrderFromQR(String qrData) async {
    try {
      // Парсинг QR-кода (в реальном приложении будет JSON или другой формат)
      final newOrder = Order(
        id: 'QR_${DateTime.now().millisecondsSinceEpoch}',
        customerName: 'Клиент QR',
        customerPhone: '+37491000000',
        pickupAddress: 'Склад CIO Logistics',
        deliveryAddress: 'Адрес из QR: $qrData',
        weight: 1.0,
        description: 'Товар со склада',
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        price: 10000.0,
        dimensions: '20x20x10 см',
        ridePrice: 10000.0,
        deliveryTime: DeliveryTime.afternoon,
        qrCode: qrData,
        priority: 0,
      );

      _orders.insert(0, newOrder);
      notifyListeners();

      debugPrint('✅ Заказ добавлен через QR-код: ${newOrder.id}');
    } catch (e) {
      debugPrint('❌ Ошибка обработки QR-кода: $e');
    }
  }

  // Отменить заказ (отмена доставки)
  Future<void> cancelOrder(String orderId, String reason) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: OrderStatus.cancelled,
        completedAt: DateTime.now(),
      );
      await _incrementCancelled();
      debugPrint('🔄 Заказ $orderId отменён. Причина: $reason');
    }
  }

  // Получить статистику для водителя
  Map<String, int> getDriverStatistics() {
    final completed =
        _orders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelled =
        _orders.where((o) => o.status == OrderStatus.cancelled).length;
    final inProgress =
        _orders.where((o) => o.status == OrderStatus.inTransit).length;

    return {
      'completed': completed,
      'cancelled': cancelled,
      'inProgress': inProgress,
      'total': _orders.length,
    };
  }

  // Сохранить статистику в SharedPreferences
  Future<void> _saveStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'order_statistics', _statistics.toJson().toString());
      debugPrint('📊 Статистика сохранена: $_statistics');
    } catch (e) {
      debugPrint('❌ Ошибка сохранения статистики: $e');
    }
  }

  // Загрузить статистику из SharedPreferences
  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString('order_statistics');
      if (statsString != null) {
        // Простой парсинг (в реальном приложении лучше использовать JSON)
        final completedMatch =
            RegExp(r'completedOrders: (\d+)').firstMatch(statsString);
        final cancelledMatch =
            RegExp(r'cancelledOrders: (\d+)').firstMatch(statsString);
        final returnedMatch =
            RegExp(r'returnedOrders: (\d+)').firstMatch(statsString);
        final totalMatch =
            RegExp(r'totalDelivered: (\d+)').firstMatch(statsString);

        _statistics = OrderStatistics(
          completedOrders:
              completedMatch != null ? int.parse(completedMatch.group(1)!) : 0,
          cancelledOrders:
              cancelledMatch != null ? int.parse(cancelledMatch.group(1)!) : 0,
          returnedOrders:
              returnedMatch != null ? int.parse(returnedMatch.group(1)!) : 0,
          totalDelivered:
              totalMatch != null ? int.parse(totalMatch.group(1)!) : 0,
        );
        debugPrint('📊 Статистика загружена: $_statistics');
      }
    } catch (e) {
      debugPrint('❌ Ошибка загрузки статистики: $e');
      _statistics = const OrderStatistics();
    }
  }

  // Увеличить счетчик завершенных заказов
  Future<void> _incrementCompleted() async {
    _statistics = _statistics.copyWith(
      completedOrders: _statistics.completedOrders + 1,
      totalDelivered: _statistics.totalDelivered + 1,
    );
    await _saveStatistics();
    notifyListeners();
  }

  // Увеличить счетчик отмененных заказов
  Future<void> _incrementCancelled() async {
    _statistics = _statistics.copyWith(
      cancelledOrders: _statistics.cancelledOrders + 1,
    );
    await _saveStatistics();
    notifyListeners();
  }

  // Увеличить счетчик возвратов
  Future<void> _incrementReturned() async {
    _statistics = _statistics.copyWith(
      returnedOrders: _statistics.returnedOrders + 1,
    );
    await _saveStatistics();
    notifyListeners();
  }

  // Обнулить статистику
  Future<void> resetStatistics() async {
    _statistics = const OrderStatistics();
    await _saveStatistics();
    notifyListeners();
    debugPrint('🔄 Статистика обнулена');
  }

  // Запросить возврат заказа (клиент звонит и просит вернуть)
  Future<void> requestReturn(String orderId, String reason) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = _orders[orderIndex];
      if (order.status == OrderStatus.delivered) {
        _orders[orderIndex] = order.copyWith(
          status: OrderStatus.returned,
          isReturn: true,
          returnRequestedAt: DateTime.now(),
          returnReason: reason,
          // Обнуляем завершение, так как заказ снова в работе
          completedAt: null,
          completionPin: null,
        );

        // Уменьшаем счетчик завершенных (так как заказ снова в работе)
        if (_statistics.completedOrders > 0) {
          _statistics = _statistics.copyWith(
            completedOrders: _statistics.completedOrders - 1,
            totalDelivered: _statistics.totalDelivered - 1,
          );
          await _saveStatistics();
        }

        notifyListeners();
        debugPrint('🔄 Запрошен возврат заказа $orderId. Причина: $reason');
      } else {
        debugPrint(
            '❌ Заказ $orderId не может быть возвращен (статус: ${order.status})');
      }
    } else {
      debugPrint('❌ Заказ $orderId не найден');
    }
  }

  // Завершить возврат (водитель забрал заказ у клиента)
  Future<void> completeReturn(String orderId, String pin) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = _orders[orderIndex];
      if (order.status == OrderStatus.returned && pin.length == 6) {
        _orders[orderIndex] = order.copyWith(
          status: OrderStatus.delivered,
          completionPin: pin,
          completedAt: DateTime.now(),
          // Сохраняем информацию о возврате
          isReturn: true,
        );

        // Увеличиваем счетчик возвратов и завершенных заказов
        await _incrementReturned();
        await _incrementCompleted();

        debugPrint('✅ Возврат заказа $orderId завершен с PIN: $pin');
      } else {
        debugPrint(
            '❌ Неверный PIN для возврата заказа $orderId или заказ не в статусе возврата');
      }
    } else {
      debugPrint('❌ Заказ $orderId не найден');
    }
  }

  // Получить заказы на возврат (только те, что нужно забрать)
  List<Order> get returnOrders =>
      _orders.where((order) => order.status == OrderStatus.returned).toList()
        ..sort((a, b) => (a.returnRequestedAt ?? DateTime.now())
            .compareTo(b.returnRequestedAt ?? DateTime.now()));

  // Проверить есть ли заказы на возврат
  bool get hasReturns => returnOrders.isNotEmpty;
}
