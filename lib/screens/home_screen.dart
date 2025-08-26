import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_app/providers/order_provider.dart';

import 'package:logistics_app/utils/app_theme.dart';
import 'package:logistics_app/utils/phone_helper.dart';
import 'package:logistics_app/widgets/order_card.dart';
import 'package:logistics_app/models/order.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Загрузка заказов при входе
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(),
            _buildTabBar(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveOrdersTab(),
            _buildInProgressOrdersTab(),
            _buildCompletedOrdersTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.primaryDarkBlue,
      foregroundColor: AppTheme.textLight,
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 4,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'CIO Logistics',
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryDarkBlue,
                AppTheme.darkCardColor,
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Статистика заказов
        Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            final stats = orderProvider.statistics;
            return PopupMenuButton<String>(
              offset: const Offset(0, 50),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Статистика водителя',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                      const Divider(),
                      _buildStatRow('Завершено', stats.completedOrders,
                          Icons.check_circle, AppTheme.statusGreen),
                      _buildStatRow('Отменено', stats.cancelledOrders,
                          Icons.cancel, AppTheme.errorRed),
                      _buildStatRow('Возвраты', stats.returnedOrders,
                          Icons.undo, AppTheme.warningAmber),
                      _buildStatRow('Всего доставлено', stats.totalDelivered,
                          Icons.local_shipping, AppTheme.primaryDarkBlue),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Обнулить статистику',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'reset') {
                  _showResetConfirmation(context, orderProvider);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 18,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.totalDelivered}',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Кнопка профиля
        IconButton(
          onPressed: () => context.go('/profile'),
          icon: Icon(
            Icons.account_circle,
            size: AppTheme.getIconSize(context, 28),
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final hasReturns = orderProvider.hasReturns;

        return SliverPersistentHeader(
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: hasReturns ? AppTheme.errorRed : AppTheme.accentOrange,
              unselectedLabelColor: AppTheme.textDark.withOpacity(0.6),
              indicatorColor:
                  hasReturns ? AppTheme.errorRed : AppTheme.accentOrange,
              indicatorWeight: 3,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 12),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontFamily: 'Roboto',
              ),
              tabs: [
                _buildTabWithCounter(
                    'Активные', OrderStatus.pending, OrderStatus.confirmed),
                _buildTabWithCounter(
                    'В работе', OrderStatus.inTransit, OrderStatus.returned),
                _buildTabWithCounter('Завершенные', OrderStatus.delivered,
                    OrderStatus.cancelled),
              ],
            ),
          ),
          pinned: true,
        );
      },
    );
  }

  Widget _buildTabWithCounter(String title, OrderStatus status1,
      [OrderStatus? status2]) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final count = orderProvider.orders.where((order) {
          return order.status == status1 ||
              (status2 != null && order.status == status2);
        }).length;

        // Определяем есть ли возвраты и это ли вкладка "В работе"
        final hasReturns = orderProvider.hasReturns;
        final isInProgressTab = title == 'В работе';
        final tabColor = (isInProgressTab && hasReturns) 
            ? AppTheme.errorRed 
            : AppTheme.accentOrange;

        return Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,

                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tabColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveOrdersTab() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final activeOrders = orderProvider.orders
            .where((order) => order.isActive)
            .toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

        if (activeOrders.isEmpty) {
          return _buildEmptyState(
            'Нет активных заказов',
            'Новые заказы появятся здесь',
            Icons.assignment_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () => orderProvider.loadOrders(),
          color: AppTheme.accentOrange,
          child: ListView.builder(
            padding: AppTheme.screenPadding,
            itemCount: activeOrders.length,
            itemBuilder: (context, index) {
              return OrderCard(
                order: activeOrders[index],
                onTakeOrder: (orderId) => _takeOrder(orderId),
                onCallCustomer: (phone) => _callCustomer(phone),
                onOpenMap: (order) => _openMap(order),
                onUpdateTracking: (orderId, tracking) =>
                    _updateTracking(orderId, tracking),
                onUpdateDeliveryTime: (orderId, time) =>
                    _updateDeliveryTime(orderId, time),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInProgressOrdersTab() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final inProgressOrders =
            orderProvider.orders.where((order) => order.isInProgress).toList()
              // Сортируем так, чтобы возвраты были всегда сверху
              ..sort((a, b) {
                if (a.isReturnOrder && !b.isReturnOrder) return -1;
                if (!a.isReturnOrder && b.isReturnOrder) return 1;
                return a.deliveryPriority.compareTo(b.deliveryPriority);
              });

        if (inProgressOrders.isEmpty) {
          return _buildEmptyState(
            'Нет заказов в работе',
            'Взятые заказы появятся здесь',
            Icons.local_shipping_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () => orderProvider.loadOrders(),
          color: AppTheme.accentOrange,
          child: ListView.builder(
            padding: AppTheme.screenPadding,
            itemCount: inProgressOrders.length,
            itemBuilder: (context, index) {
              return OrderCard(
                order: inProgressOrders[index],
                onCompleteOrder: inProgressOrders[index].isReturnOrder
                    ? (orderId, pin) => _completeReturn(orderId, pin)
                    : (orderId, pin) => _completeOrder(orderId, pin),
                onCallCustomer: (phone) => _callCustomer(phone),
                onOpenMap: (order) => _openMap(order),
                onUpdateTracking: (orderId, tracking) =>
                    _updateTracking(orderId, tracking),
                onUpdateDeliveryTime: (orderId, time) =>
                    _updateDeliveryTime(orderId, time),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCompletedOrdersTab() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final completedOrders = orderProvider.orders
            .where((order) => order.isCompleted)
            .toList()
          ..sort((a, b) => (b.completedAt ?? DateTime.now())
              .compareTo(a.completedAt ?? DateTime.now()));

        if (completedOrders.isEmpty) {
          return _buildEmptyState(
            'Нет завершенных заказов',
            'Выполненные заказы появятся здесь',
            Icons.check_circle_outline,
          );
        }

        return RefreshIndicator(
          onRefresh: () => orderProvider.loadOrders(),
          color: AppTheme.accentOrange,
          child: ListView.builder(
            padding: AppTheme.screenPadding,
            itemCount: completedOrders.length,
            itemBuilder: (context, index) {
              return OrderCard(
                order: completedOrders[index],
                isCompleted: true,
                onCallCustomer: (phone) => _callCustomer(phone),
                onOpenMap: (order) => _openMap(order),
                onUpdateTracking: (orderId, tracking) =>
                    _updateTracking(orderId, tracking),
                onUpdateDeliveryTime: (orderId, time) =>
                    _updateDeliveryTime(orderId, time),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: AppTheme.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.textDark.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textDark.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textDark.withOpacity(0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0, // Всегда на главной
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
        if (index == 1) {
          // Открыть карту
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Карта маршрутов - в разработке'),
              backgroundColor: AppTheme.accentOrange,
            ),
          );
        } else if (index == 2) {
          // Открыть QR-сканер
          context.go('/qr-scanner');
        }
      },
    );
  }

  Future<void> _takeOrder(String orderId) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.takeOrder(orderId);
  }

  Future<void> _completeOrder(String orderId, String pin) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.completeOrder(orderId, pin);
  }

  Future<void> _completeReturn(String orderId, String pin) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.completeReturn(orderId, pin);
  }

  void _callCustomer(String phone) {
    PhoneHelper.makeCall(phone);
  }

  void _openMap(Order order) {
    // TODO: Открыть карту с адресом
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Карта: ${order.deliveryAddress}'),
        backgroundColor: AppTheme.primaryDarkBlue,
      ),
    );
  }

  Future<void> _updateTracking(String orderId, String trackingNumber) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.updateTrackingNumber(orderId, trackingNumber);
  }

  Future<void> _updateDeliveryTime(
      String orderId, DeliveryTime deliveryTime) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.updateDeliveryTime(orderId, deliveryTime);
  }

  Widget _buildStatRow(String label, int value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(
      BuildContext context, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Обнулить статистику?',
            style: TextStyle(
              color: AppTheme.primaryDarkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Все счетчики завершенных, отмененных и возвращенных заказов будут обнулены. Это действие нельзя отменить.',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await orderProvider.resetStatistics();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Статистика обнулена',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context, 16),
                      ),
                    ),
                    backgroundColor: AppTheme.statusGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.textLight,
              ),
              child: Text(
                'Обнулить',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Делегат для TabBar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundWhite,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
