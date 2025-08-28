import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_app/utils/app_theme.dart';

class DebugMapScreen extends StatefulWidget {
  const DebugMapScreen({super.key});

  @override
  State<DebugMapScreen> createState() => _DebugMapScreenState();
}

class _DebugMapScreenState extends State<DebugMapScreen> {
  GoogleMapController? _mapController;
  List<String> _debugInfo = [];
  bool _mapLoaded = false;

  // Простая позиция в Москве
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(55.7558, 37.6176),
    zoom: 10,
  );

  void _addDebugInfo(String info) {
    setState(() {
      _debugInfo.add('${DateTime.now().toLocal()}: $info');
    });
    print('DEBUG: $info');
  }

  @override
  void initState() {
    super.initState();
    _addDebugInfo('Инициализация Debug Map Screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Диагностика карты'),
        backgroundColor: AppTheme.primaryDarkBlue,
        foregroundColor: AppTheme.textLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showDebugDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Статус панель
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _mapLoaded ? AppTheme.statusGreen : AppTheme.accentOrange,
            child: Text(
              _mapLoaded ? 'Карта загружена успешно!' : 'Загрузка карты...',
              style: const TextStyle(
                color: AppTheme.textLight,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Карта
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _addDebugInfo('Google Map создана успешно');
                setState(() {
                  _mapLoaded = true;
                });
              },
              markers: {
                const Marker(
                  markerId: MarkerId('moscow_center'),
                  position: LatLng(55.7558, 37.6176),
                  infoWindow: InfoWindow(
                    title: 'Центр Москвы',
                    snippet: 'Тестовый маркер',
                  ),
                ),
              },
              myLocationEnabled: false, // Отключаем геолокацию для упрощения
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
          ),

          // Лог отладки
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Лог отладки:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _debugInfo.length,
                      itemBuilder: (context, index) {
                        return Text(
                          _debugInfo[index],
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Информация для диагностики'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('API ключ Android: AIzaSyC74hkEcM-iXe4Es7nFrq7KhDDjZlLek9I'),
              const SizedBox(height: 8),
              Text('API ключ iOS: AIzaSyD_dAlWB42IkbQLbGWUC79fNdLo7jT9Ri8'),
              const SizedBox(height: 8),
              Text('Карта загружена: ${_mapLoaded ? "Да" : "Нет"}'),
              const SizedBox(height: 8),
              Text('Количество записей в логе: ${_debugInfo.length}'),
              const SizedBox(height: 16),
              const Text(
                'Если карта не загружается:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('1. Проверьте подключение к интернету'),
              const Text('2. Убедитесь, что включен Maps SDK for Android'),
              const Text('3. Проверьте, что API ключ не ограничен'),
              const Text(
                  '4. Убедитесь, что устройство имеет Google Play Services'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
