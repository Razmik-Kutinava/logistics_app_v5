import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart' as perm_handler;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logistics_app/utils/app_theme.dart';
import 'package:logistics_app/providers/order_provider.dart';
import 'package:logistics_app/models/order.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  location.LocationData? _currentLocation;
  final location.Location _location = location.Location();
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};

  // Москва как центр по умолчанию
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(55.7558, 37.6176),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _checkPermissions();
      await _getCurrentLocation();
      await _loadOrderMarkers();
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка инициализации карты: $e';
      });
      print('Ошибка инициализации карты: $e');
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Проверяем статус разрешения
      var status = await perm_handler.Permission.location.status;

      if (status.isDenied) {
        // Запрашиваем разрешение
        status = await perm_handler.Permission.location.request();
      }

      if (status.isGranted) {
        print('Разрешение на геолокацию получено');
      } else if (status.isDenied) {
        throw Exception(
            'Разрешение на геолокацию отклонено. Включите разрешение в настройках приложения.');
      } else if (status.isPermanentlyDenied) {
        throw Exception(
            'Разрешение на геолокацию постоянно отклонено. Перейдите в настройки приложения для включения.');
      }
    } catch (e) {
      print('Ошибка проверки разрешений: $e');
      rethrow;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      location.PermissionStatus permissionGranted =
          await _location.hasPermission();
      if (permissionGranted == location.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != location.PermissionStatus.granted) {
          return;
        }
      }

      // Получаем местоположение с таймаутом
      _currentLocation = await _location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Таймаут получения местоположения');
          throw Exception(
              'Не удалось получить местоположение в течение 10 секунд');
        },
      );

      if (_currentLocation != null &&
          _currentLocation!.latitude != null &&
          _currentLocation!.longitude != null) {
        print(
            'Местоположение получено: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');
        // Добавляем маркер текущего местоположения
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(
              title: 'Ваше местоположение',
              snippet: 'Текущая позиция',
            ),
          ),
        );
      }
    } catch (e) {
      print('Ошибка получения местоположения: $e');
    }
  }

  Future<void> _loadOrderMarkers() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final orders = orderProvider.orders;

    // Очищаем предыдущие маркеры заказов
    _markers
        .removeWhere((marker) => marker.markerId.value.startsWith('order_'));

    for (final order in orders) {
      if (order.deliveryAddress.isNotEmpty) {
        // В реальном приложении здесь был бы геокодинг адреса
        // Для демо создаем случайные координаты в Москве
        final latLng = _generateRandomLocationInMoscow();

        double markerHue;
        String snippet;

        switch (order.status) {
          case OrderStatus.pending:
          case OrderStatus.confirmed:
            markerHue = BitmapDescriptor.hueOrange;
            snippet = 'Ожидает выполнения';
            break;
          case OrderStatus.inTransit:
            markerHue = BitmapDescriptor.hueYellow;
            snippet = 'В пути';
            break;
          case OrderStatus.delivered:
            markerHue = BitmapDescriptor.hueGreen;
            snippet = 'Доставлен';
            break;
          case OrderStatus.cancelled:
            markerHue = BitmapDescriptor.hueRed;
            snippet = 'Отменен';
            break;
          case OrderStatus.returned:
            markerHue = BitmapDescriptor.hueViolet;
            snippet = 'Возврат';
            break;
        }

        _markers.add(
          Marker(
            markerId: MarkerId('order_${order.id}'),
            position: latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
            infoWindow: InfoWindow(
              title: 'Заказ #${order.id}',
              snippet: snippet,
            ),
            onTap: () => _showOrderBottomSheet(order),
          ),
        );
      }
    }
  }

  LatLng _generateRandomLocationInMoscow() {
    // Генерируем случайные координаты в пределах Москвы
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final lat = 55.7558 + (random / 10000 - 0.05); // ±0.05 градуса
    final lng = 37.6176 + (random / 5000 - 0.1); // ±0.1 градуса
    return LatLng(lat, lng);
  }

  void _showOrderBottomSheet(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Полоска для перетаскивания
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textDark.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Заголовок
            Text(
              'Заказ #${order.id}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDarkBlue,
                  ),
            ),
            const SizedBox(height: 16),

            // Статус
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(order).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: _getStatusColor(order).withOpacity(0.3)),
              ),
              child: Text(
                order.statusText,
                style: TextStyle(
                  color: _getStatusColor(order),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Адрес
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  color: AppTheme.primaryDarkBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Клиент
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppTheme.primaryDarkBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  order.customerName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Телефон
            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: AppTheme.primaryDarkBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  order.customerPhone,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),

            const Spacer(),

            // Кнопка навигации
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Открыть навигацию в Google Maps
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Навигация - в разработке'),
                      backgroundColor: AppTheme.accentOrange,
                    ),
                  );
                },
                icon: const Icon(Icons.directions),
                label: const Text('Построить маршрут'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: AppTheme.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Карта заказов'),
        backgroundColor: AppTheme.primaryDarkBlue,
        foregroundColor: AppTheme.textLight,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMap,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentOrange,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.errorRed,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _initializeMap();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentOrange,
                            foregroundColor: AppTheme.textLight,
                          ),
                          child: const Text('Попробовать снова'),
                        ),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: _currentLocation != null
                      ? CameraPosition(
                          target: LatLng(
                            _currentLocation!.latitude!,
                            _currentLocation!.longitude!,
                          ),
                          zoom: 14,
                        )
                      : _defaultPosition,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    print('Google Map успешно создана');
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1, // Карта активна
      backgroundColor: AppTheme.backgroundWhite,
      selectedItemColor: AppTheme.accentOrange,
      unselectedItemColor: AppTheme.textDark.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment, size: AppTheme.getIconSize(context, 26)),
          label: 'Заказы',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map, size: AppTheme.getIconSize(context, 26)),
          label: 'Карта',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner,
              size: AppTheme.getIconSize(context, 26)),
          label: 'Сканер',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          context.go('/home');
        } else if (index == 2) {
          context.go('/qr-scanner');
        }
      },
    );
  }

  void _goToCurrentLocation() async {
    if (_currentLocation != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
        ),
      );
    }
  }

  Color _getStatusColor(Order order) {
    if (order.isReturnOrder) {
      return AppTheme.errorRed;
    }
    return AppTheme.getOrderStatusColor(
      order.status.toString().split('.').last,
    );
  }

  void _refreshMap() async {
    setState(() {
      _isLoading = true;
    });
    await _loadOrderMarkers();
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Карта обновлена'),
        backgroundColor: AppTheme.statusGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
