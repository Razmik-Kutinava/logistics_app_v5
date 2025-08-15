import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logistics_app/providers/auth_provider.dart';
import 'package:logistics_app/providers/theme_provider.dart';
import 'package:logistics_app/utils/app_theme.dart';
import 'package:logistics_app/models/driver.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Driver? _currentDriver;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  void _loadDriverData() {
    // Демо данные водителя
    _currentDriver = Driver(
      id: 'driver_001',
      fullName: 'Арам Григорян',
      phone: '+37491123456',
      email: 'aram.grigoryan@cio-logistics.am',
      passportNumber: 'AN1234567',
      passportIssuedBy: 'МВД РА',
      passportIssuedDate: DateTime(2015, 3, 15),
      licenseNumber: 'VOD123456',
      licenseCategory: 'B, C',
      licenseIssuedDate: DateTime(2014, 8, 20),
      licenseExpiryDate: DateTime(2029, 8, 20),
      completedRides: 1247,
      cancelledRides: 23,
      rating: 4.8,
      workStartDate: DateTime(2021, 5, 10),
      isActive: true,
      receiveNotifications: true,
      isOnline: true,
      lastActiveAt: DateTime.now(),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: _buildAppBar(),
      body: _currentDriver == null
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: AppTheme.screenPadding,
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatisticsCards(),
                  const SizedBox(height: 24),
                  _buildPersonalInfo(),
                  const SizedBox(height: 24),
                  _buildDocuments(),
                  const SizedBox(height: 24),
                  _buildSettings(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
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

  Widget _buildProfileHeader() {
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
              child: _currentDriver!.profilePhoto != null
                  ? Image.network(
                      _currentDriver!.profilePhoto!,
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
            _currentDriver!.fullName,
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
              color: _currentDriver!.isOnline
                  ? AppTheme.statusGreen
                  : AppTheme.completedGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _currentDriver!.isOnline ? Icons.circle : Icons.offline_bolt,
                  size: 16,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentDriver!.statusText,
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

          // Опыт работы и рейтинг
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderStat(
                  'Опыт', _currentDriver!.experienceText, Icons.work),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textLight.withOpacity(0.3),
              ),
              _buildHeaderStat(
                  'Рейтинг', _currentDriver!.ratingFormatted, Icons.star),
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
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Завершено',
            '${_currentDriver!.completedRides}',
            Icons.check_circle,
            AppTheme.statusGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Возвратов',
            '${_currentDriver!.cancelledRides}',
            Icons.cancel,
            AppTheme.errorRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Успешность',
            _currentDriver!.successRateText,
            Icons.trending_up,
            AppTheme.accentOrange,
          ),
        ),
      ],
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

  Widget _buildPersonalInfo() {
    return _buildSection(
      'Личные данные',
      Icons.person,
      [
        _buildInfoRow('ФИО', _currentDriver!.fullName),
        _buildInfoRow('Телефон', _currentDriver!.phoneFormatted),
        if (_currentDriver!.email != null)
          _buildInfoRow('Email', _currentDriver!.email!),
      ],
    );
  }

  Widget _buildDocuments() {
    return Column(
      children: [
        // Паспортные данные
        _buildSection(
          'Паспортные данные',
          Icons.credit_card,
          [
            if (_currentDriver!.passportNumber != null)
              _buildInfoRow('Номер', _currentDriver!.passportNumber!),
            if (_currentDriver!.passportIssuedBy != null)
              _buildInfoRow('Выдан', _currentDriver!.passportIssuedBy!),
            if (_currentDriver!.passportIssuedDate != null)
              _buildInfoRow(
                'Дата выдачи',
                '${_currentDriver!.passportIssuedDate!.day}.${_currentDriver!.passportIssuedDate!.month}.${_currentDriver!.passportIssuedDate!.year}',
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Водительские права
        _buildSection(
          'Водительские права',
          Icons.directions_car,
          [
            if (_currentDriver!.licenseNumber != null)
              _buildInfoRow('Номер', _currentDriver!.licenseNumber!),
            if (_currentDriver!.licenseCategory != null)
              _buildInfoRow('Категория', _currentDriver!.licenseCategory!),
            if (_currentDriver!.licenseExpiryDate != null)
              _buildInfoRow(
                'Действительны до',
                '${_currentDriver!.licenseExpiryDate!.day}.${_currentDriver!.licenseExpiryDate!.month}.${_currentDriver!.licenseExpiryDate!.year}',
                isValid: _currentDriver!.isLicenseValid,
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

  Widget _buildSettings() {
    return _buildSection(
      'Настройки',
      Icons.settings,
      [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return _buildSwitchRow(
              'Темная тема',
              themeProvider.isDarkMode,
              (value) => themeProvider.toggleTheme(),
            );
          },
        ),
        _buildSwitchRow(
          'Push-уведомления',
          _currentDriver!.receiveNotifications,
          (value) {
            // TODO: Обновить настройки уведомлений
          },
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentOrange,
            activeTrackColor: AppTheme.accentOrange.withOpacity(0.3),
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
}
