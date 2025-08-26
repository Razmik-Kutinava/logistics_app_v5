import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logistics_app/models/order.dart';
import 'package:logistics_app/utils/app_theme.dart';
import 'package:logistics_app/utils/phone_helper.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final Function(String)? onTakeOrder;
  final Function(String, String)? onCompleteOrder;
  final Function(String)? onCallCustomer;
  final Function(Order)? onOpenMap;

  final Function(String, String)?
      onUpdateTracking; // Новый callback для обновления трекера
  final Function(String, DeliveryTime)?
      onUpdateDeliveryTime; // Callback для обновления времени доставки
  final bool isCompleted;

  const OrderCard({
    super.key,
    required this.order,
    this.onTakeOrder,
    this.onCompleteOrder,
    this.onCallCustomer,
    this.onOpenMap,
    this.onUpdateTracking,
    this.onUpdateDeliveryTime,
    this.isCompleted = false,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final _pinController = TextEditingController();
  final _trackingController = TextEditingController();
  int _callCount = 0;

  @override
  void initState() {
    super.initState();
    // Инициализация поля трекера текущим значением
    _trackingController.text = widget.order.trackingNumber ?? '';
    // Загружаем счетчик звонков для этого заказа
    _loadCallCount();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.order.isReturnOrder) {
      return AppTheme.errorRed; // Красный цвет для возвратов
    }
    // Передаём только часть после точки, чтобы совпадали ключи цветов
    return AppTheme.getOrderStatusColor(
      widget.order.status.toString().split('.').last,
    );
  }

  // Загружаем счетчик звонков для конкретного заказа
  Future<void> _loadCallCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('call_count_${widget.order.id}') ?? 0;
      if (mounted) {
        setState(() {
          _callCount = count;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки счетчика звонков: $e');
    }
  }

  // Сохраняем и увеличиваем счетчик звонков
  Future<void> _incrementCallCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newCount = _callCount + 1;
      await prefs.setInt('call_count_${widget.order.id}', newCount);
      if (mounted) {
        setState(() {
          _callCount = newCount;
        });
      }
    } catch (e) {
      debugPrint('Ошибка сохранения счетчика звонков: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: widget.isCompleted ? 4 : 8,
      color: widget.isCompleted
          ? AppTheme.backgroundWhite.withOpacity(0.8)
          : AppTheme.backgroundWhite,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _statusColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: AppTheme.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildAddressSection(),
              const SizedBox(height: 16),
              _buildOrderDetails(),
              const SizedBox(height: 16),
              _buildCustomerInfo(),
              if (!widget.isCompleted) ...[
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
              // PIN-поле всегда показывается для заказов "В работе"
              if (widget.order.isInProgress) ...[
                const SizedBox(height: 16),
                _buildPinField(),
              ],

              // Информация о возврате для заказов на возврат
              if (widget.order.isReturnOrder) ...[
                const SizedBox(height: 16),
                _buildReturnInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Статус заказа
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.order.statusText,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        // Цена рейса
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentOrange.withOpacity(0.3),
            ),
          ),
          child: Text(
            widget.order.ridePriceFormatted,
            style: TextStyle(
              color: AppTheme.accentOrange,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDarkBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryDarkBlue.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.primaryDarkBlue,
                size: AppTheme.getIconSize(context, 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Адрес доставки',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryDarkBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => widget.onOpenMap?.call(widget.order),
                icon: Icon(
                  Icons.map,
                  color: AppTheme.accentOrange,
                  size: AppTheme.getIconSize(context, 24),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.order.deliveryAddress,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: AppTheme.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: AppTheme.textDark, // Темный цвет для адреса
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      children: [
        _buildTrackingField(),
        const SizedBox(height: 12),
        _buildDetailRow(
          'Габариты / вес',
          '${widget.order.dimensions} / ${widget.order.weightFormatted}',
          Icons.inventory_2,
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          'Описание',
          widget.order.description,
          Icons.description,
        ),
        const SizedBox(height: 12),
        _buildDeliveryTimeField(),
      ],
    );
  }

  Widget _buildDeliveryTimeField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDarkBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryDarkBlue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppTheme.primaryDarkBlue,
                size: AppTheme.getIconSize(context, 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Время доставки',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryDarkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DeliveryTime>(
            value: widget.order.deliveryTime,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: AppTheme.primaryDarkBlue.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: AppTheme.primaryDarkBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppTheme.primaryDarkBlue, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
            items: DeliveryTime.values.map((DeliveryTime time) {
              return DropdownMenuItem<DeliveryTime>(
                value: time,
                child: Row(
                  children: [
                    Icon(
                      _getDeliveryTimeIcon(time),
                      color: _getDeliveryTimeColor(time),
                      size: AppTheme.getIconSize(context, 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getDeliveryTimeText(time),
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: _getDeliveryTimeColor(time),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: widget.isCompleted
                ? null
                : (DeliveryTime? newTime) {
                    if (newTime != null) {
                      widget.onUpdateDeliveryTime
                          ?.call(widget.order.id, newTime);
                      // Показать подтверждение
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Время доставки обновлено: ${_getDeliveryTimeText(newTime)}',
                            style: TextStyle(
                              fontSize:
                                  AppTheme.getResponsiveFontSize(context, 16),
                            ),
                          ),
                          backgroundColor: AppTheme.primaryDarkBlue,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }

  IconData _getDeliveryTimeIcon(DeliveryTime time) {
    switch (time) {
      case DeliveryTime.urgent:
        return Icons.flash_on;
      case DeliveryTime.oneHour:
        return Icons.access_time;
      case DeliveryTime.twoHours:
        return Icons.schedule;
      case DeliveryTime.threeHours:
        return Icons.update;
      case DeliveryTime.morning:
        return Icons.wb_sunny;
      case DeliveryTime.afternoon:
        return Icons.wb_cloudy;
      case DeliveryTime.evening:
        return Icons.nights_stay;
    }
  }

  Color _getDeliveryTimeColor(DeliveryTime time) {
    switch (time) {
      case DeliveryTime.urgent:
        return AppTheme.errorRed;
      case DeliveryTime.oneHour:
        return AppTheme.accentOrange;
      case DeliveryTime.twoHours:
        return AppTheme.warningAmber;
      case DeliveryTime.threeHours:
        return AppTheme.primaryDarkBlue;
      case DeliveryTime.morning:
        return AppTheme.statusGreen;
      case DeliveryTime.afternoon:
        return AppTheme.primaryDarkBlue;
      case DeliveryTime.evening:
        return AppTheme.completedGray;
    }
  }

  String _getDeliveryTimeText(DeliveryTime time) {
    switch (time) {
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

  Widget _buildTrackingField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentOrange.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code,
                color: AppTheme.accentOrange,
                size: AppTheme.getIconSize(context, 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Трекер груза',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _trackingController,
            enabled:
                !widget.isCompleted, // Нельзя редактировать завершенные заказы
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
            decoration: InputDecoration(
              hintText: 'Введите номер трекера',
              hintStyle: TextStyle(
                color: AppTheme.textDark.withOpacity(0.5),
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
              ),
              prefixIcon: Icon(
                Icons.local_shipping,
                color: AppTheme.accentOrange,
                size: AppTheme.getIconSize(context, 24),
              ),
              suffixIcon:
                  _trackingController.text.isNotEmpty && !widget.isCompleted
                      ? IconButton(
                          icon: Icon(
                            Icons.save,
                            color: AppTheme.statusGreen,
                            size: AppTheme.getIconSize(context, 24),
                          ),
                          onPressed: () {
                            if (_trackingController.text.trim().isNotEmpty) {
                              widget.onUpdateTracking?.call(
                                widget.order.id,
                                _trackingController.text.trim(),
                              );
                              // Показать подтверждение
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Трекер обновлен: ${_trackingController.text.trim()}',
                                    style: TextStyle(
                                      fontSize: AppTheme.getResponsiveFontSize(
                                          context, 16),
                                    ),
                                  ),
                                  backgroundColor: AppTheme.statusGreen,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        )
                      : null,
              filled: true,
              fillColor: widget.isCompleted
                  ? AppTheme.completedGray.withOpacity(0.1)
                  : AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppTheme.accentOrange.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppTheme.accentOrange.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.accentOrange, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppTheme.completedGray.withOpacity(0.3)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            onChanged: (value) {
              setState(
                  () {}); // Обновляем состояние для показа кнопки сохранения
            },
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty && !widget.isCompleted) {
                widget.onUpdateTracking?.call(widget.order.id, value.trim());
              }
            },
          ),
          if (_trackingController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Текущий трекер: ${_trackingController.text}',
              style: TextStyle(
                color: AppTheme.textDark.withOpacity(0.6),
                fontSize: AppTheme.getResponsiveFontSize(context, 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryDarkBlue.withOpacity(0.7),
          size: AppTheme.getIconSize(context, 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: AppTheme.getResponsiveFontSize(context, 14),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      color: AppTheme.textDark, // Темный цвет для значений
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.statusGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.statusGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppTheme.statusGreen,
                size: AppTheme.getIconSize(context, 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Получатель',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.statusGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.order.customerName,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: AppTheme.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark, // Темный цвет для лучшей видимости
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.phone,
                color: AppTheme.primaryDarkBlue,
                size: AppTheme.getIconSize(context, 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  PhoneHelper.formatPhoneNumber(widget.order.customerPhone),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: AppTheme.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: AppTheme
                            .primaryDarkBlue, // Темно-синий для номера телефона
                      ),
                ),
              ),
              // Счетчик звонков
              if (_callCount > 0) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentOrange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.call_made,
                        size: 14,
                        color: AppTheme.accentOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_callCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Кнопка звонка
              IconButton(
                onPressed: () async {
                  // Увеличиваем счетчик при нажатии
                  await _incrementCallCount();
                  // Показываем диалог звонка
                  PhoneHelper.showContactDialog(
                    context,
                    widget.order.customerPhone,
                    widget.order.customerName,
                  );
                },
                icon: Icon(
                  Icons.call,
                  color: AppTheme.statusGreen,
                  size: AppTheme.getIconSize(context, 24),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.statusGreen.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.order.isActive) {
      return SizedBox(
        width: double.infinity,
        height: AppTheme.getButtonHeight(context),
        child: ElevatedButton(
          onPressed: () => widget.onTakeOrder?.call(widget.order.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentOrange,
            foregroundColor: AppTheme.textLight,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in,
                size: AppTheme.getIconSize(context, 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Взять в работу',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      );
    } else if (widget.order.isInProgress) {
      // Для заказов "В работе" кнопка отсутствует, так как PIN-поле всегда видно
      return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  Widget _buildPinField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.statusGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.statusGreen.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: AppTheme.statusGreen,
                size: AppTheme.getIconSize(context, 24),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.order.isReturnOrder
                      ? 'PIN-код для возврата'
                      : 'PIN-код для завершения',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.statusGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.order.isReturnOrder
                ? 'Получите PIN от клиента для завершения возврата'
                : 'Получите PIN от клиента для завершения',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDark.withOpacity(0.7),
                  fontSize: AppTheme.getResponsiveFontSize(context, 13),
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (value) {
              setState(() {}); // Обновляем состояние кнопки при вводе
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: AppTheme.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: AppTheme.textDark,
                ),
            decoration: InputDecoration(
              hintText: '••••••',
              hintStyle: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 20),
                letterSpacing: 3,
                color: AppTheme.textDark.withOpacity(0.3),
              ),
              counterText: '',
              prefixIcon: Icon(
                Icons.pin,
                color: AppTheme.statusGreen,
                size: AppTheme.getIconSize(context, 28),
              ),
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.statusGreen, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppTheme.statusGreen.withOpacity(0.5), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.statusGreen, width: 3),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: AppTheme.getButtonHeight(context),
            child: ElevatedButton(
              onPressed: _pinController.text.length == 6
                  ? () {
                      widget.onCompleteOrder?.call(
                        widget.order.id,
                        _pinController.text,
                      );
                      _pinController.clear();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pinController.text.length == 6
                    ? AppTheme.statusGreen
                    : AppTheme.completedGray,
                foregroundColor: AppTheme.textLight,
                elevation: _pinController.text.length == 6 ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: AppTheme.getIconSize(context, 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.order.isReturnOrder
                        ? 'Завершить возврат'
                        : 'Завершить доставку',
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
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

  Widget _buildReturnInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorRed.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppTheme.errorRed,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'ВОЗВРАТ ЗАКАЗА',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.order.returnReason != null) ...[
            Text(
              'Причина: ${widget.order.returnReason}',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.order.returnRequestedAt != null) ...[
            Text(
              'Запрошен: ${_formatDateTime(widget.order.returnRequestedAt!)}',
              style: TextStyle(
                color: AppTheme.textDark.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
