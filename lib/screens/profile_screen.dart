import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logistics_app/providers/auth_provider.dart';
import 'package:logistics_app/providers/order_provider.dart';
import 'package:logistics_app/utils/app_theme.dart';
import 'package:logistics_app/models/driver.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final Driver? driver = authProvider.driver;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: _buildAppBar(),
      body: driver == null
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: AppTheme.screenPadding,
              child: Column(
                children: [
                  _buildProfileHeader(driver),
                  const SizedBox(height: 24),
                  _buildStatisticsCards(),
                  const SizedBox(height: 24),
                  _buildPersonalInfo(driver),
                  const SizedBox(height: 24),
                  _buildDocuments(driver),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 16),
                  _buildResetStatisticsButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Профиль водителя'),
      backgroundColor: AppTheme.primaryDarkBlue,
      foregroundColor: AppTheme.textLight,
      elevation: 2,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => context.go('/home'),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            // TODO: Редактирование профиля
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Редактирование профиля - в разработке'),
                backgroundColor: AppTheme.accentOrange,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.accentOrange,
      ),
    );
  }

  Widget _buildProfileHeader(Driver driver) {
    return Container(
      padding: AppTheme.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.darkCardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDarkBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Аватар
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.backgroundWhite,
              border: Border.all(
                color: AppTheme.accentOrange,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: driver.profilePhoto != null
                  ? Image.network(
                      driver.profilePhoto!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),

          const SizedBox(height: 16),

          // Имя
          Text(
            driver.fullName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Статус
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: driver.isOnline
                  ? AppTheme.statusGreen
                  : AppTheme.completedGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  driver.isOnline ? Icons.circle : Icons.offline_bolt,
                  size: 16,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: 8),
                Text(
                  driver.statusText,
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Опыт работы
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderStat(
                  'Опыт работы', driver.experienceText, Icons.work),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppTheme.primaryDarkBlue.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 50,
        color: AppTheme.primaryDarkBlue,
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.accentOrange,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textLight.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final stats = orderProvider.statistics;
        final totalOrders = stats.completedOrders + stats.cancelledOrders;
        final successRate = totalOrders > 0
            ? ((stats.completedOrders / totalOrders) * 100).round()
            : 0;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Завершено',
                '${stats.completedOrders}',
                Icons.check_circle,
                AppTheme.statusGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Отменено',
                '${stats.cancelledOrders}',
                Icons.cancel,
                AppTheme.errorRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Успешность',
                '$successRate%',
                Icons.trending_up,
                AppTheme.accentOrange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDark.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(Driver driver) {
    return _buildSection(
      'Личные данные',
      Icons.person,
      [
        _buildInfoRow('ФИО', driver.fullName),
        _buildInfoRow('Телефон', driver.phoneFormatted),
        if (driver.email != null) _buildInfoRow('Email', driver.email!),
      ],
    );
  }

  Widget _buildDocuments(Driver driver) {
    return Column(
      children: [
        // Паспортные данные
        _buildSection(
          'Паспортные данные',
          Icons.credit_card,
          [
            if (driver.passportNumber != null)
              _buildInfoRow('Номер', driver.passportNumber!),
            if (driver.passportIssuedBy != null)
              _buildInfoRow('Выдан', driver.passportIssuedBy!),
            if (driver.passportIssuedDate != null)
              _buildInfoRow(
                'Дата выдачи',
                '${driver.passportIssuedDate!.day}.${driver.passportIssuedDate!.month}.${driver.passportIssuedDate!.year}',
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Водительские права
        _buildSection(
          'Водительские права',
          Icons.directions_car,
          [
            if (driver.licenseNumber != null)
              _buildInfoRow('Номер', driver.licenseNumber!),
            if (driver.licenseCategory != null)
              _buildInfoRow('Категория', driver.licenseCategory!),
            if (driver.licenseExpiryDate != null)
              _buildInfoRow(
                'Действительны до',
                '${driver.licenseExpiryDate!.day}.${driver.licenseExpiryDate!.month}.${driver.licenseExpiryDate!.year}',
                isValid: driver.isLicenseValid,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: AppTheme.cardPadding,
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryDarkBlue.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryDarkBlue,
                size: AppTheme.getIconSize(context, 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryDarkBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool? isValid}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isValid == false ? AppTheme.errorRed : null,
                        ),
                  ),
                ),
                if (isValid != null)
                  Icon(
                    isValid ? Icons.check_circle : Icons.error,
                    size: 20,
                    color: isValid ? AppTheme.statusGreen : AppTheme.errorRed,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.getButtonHeight(context),
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorRed,
          side: BorderSide(color: AppTheme.errorRed, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              size: AppTheme.getIconSize(context, 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Выйти из аккаунта',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetStatisticsButton() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final stats = orderProvider.statistics;
        final hasData = stats.completedOrders > 0 ||
            stats.cancelledOrders > 0 ||
            stats.returnedOrders > 0;

        return SizedBox(
          width: double.infinity,
          height: AppTheme.getButtonHeight(context),
          child: OutlinedButton(
            onPressed: hasData ? () => _showResetStatisticsDialog() : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentOrange,
              side: BorderSide(
                  color: hasData
                      ? AppTheme.accentOrange
                      : AppTheme.accentOrange.withOpacity(0.3),
                  width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: AppTheme.getIconSize(context, 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Сбросить статистику',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: hasData
                            ? AppTheme.accentOrange
                            : AppTheme.accentOrange.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1, // Профиль
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
          icon: Icon(Icons.person, size: AppTheme.getIconSize(context, 26)),
          label: 'Профиль',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          context.go('/home');
        }
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Выход из аккаунта'),
        content: Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _showResetStatisticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.accentOrange),
            const SizedBox(width: 8),
            Text('Сброс статистики'),
          ],
        ),
        content: Text(
          'Вы уверены, что хотите сбросить всю статистику заказов?\n\nЭто действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final orderProvider =
                  Provider.of<OrderProvider>(context, listen: false);
              await orderProvider.resetStatistics();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Статистика сброшена'),
                    backgroundColor: AppTheme.statusGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
            ),
            child: Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}
