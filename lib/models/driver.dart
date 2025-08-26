class Driver {
  final String id;
  final String fullName;
  final String phone;
  final String? email;

  // Паспортные данные
  final String? passportNumber;
  final String? passportIssuedBy;
  final DateTime? passportIssuedDate;
  final String? passportPhoto;

  // Водительские данные
  final String? licenseNumber;
  final String? licenseCategory;
  final DateTime? licenseIssuedDate;
  final DateTime? licenseExpiryDate;
  final String? licensePhoto;

  // Статистика
  final int completedRides;
  final int cancelledRides;
  final DateTime workStartDate;

  // Настройки
  final bool isActive;
  final bool receiveNotifications;
  final String? profilePhoto;

  // Текущий статус
  final bool isOnline;
  final DateTime? lastActiveAt;

  Driver({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.completedRides,
    required this.cancelledRides,
    required this.workStartDate,
    this.email,
    this.passportNumber,
    this.passportIssuedBy,
    this.passportIssuedDate,
    this.passportPhoto,
    this.licenseNumber,
    this.licenseCategory,
    this.licenseIssuedDate,
    this.licenseExpiryDate,
    this.licensePhoto,
    this.isActive = true,
    this.receiveNotifications = true,
    this.profilePhoto,
    this.isOnline = false,
    this.lastActiveAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      passportNumber: json['passportNumber'] as String?,
      passportIssuedBy: json['passportIssuedBy'] as String?,
      passportIssuedDate: json['passportIssuedDate'] != null
          ? DateTime.parse(json['passportIssuedDate'] as String)
          : null,
      passportPhoto: json['passportPhoto'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      licenseCategory: json['licenseCategory'] as String?,
      licenseIssuedDate: json['licenseIssuedDate'] != null
          ? DateTime.parse(json['licenseIssuedDate'] as String)
          : null,
      licenseExpiryDate: json['licenseExpiryDate'] != null
          ? DateTime.parse(json['licenseExpiryDate'] as String)
          : null,
      licensePhoto: json['licensePhoto'] as String?,
      completedRides: json['completedRides'] as int? ?? 0,
      cancelledRides: json['cancelledRides'] as int? ?? 0,
      workStartDate: DateTime.parse(json['workStartDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      receiveNotifications: json['receiveNotifications'] as bool? ?? true,
      profilePhoto: json['profilePhoto'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'passportNumber': passportNumber,
      'passportIssuedBy': passportIssuedBy,
      'passportIssuedDate': passportIssuedDate?.toIso8601String(),
      'passportPhoto': passportPhoto,
      'licenseNumber': licenseNumber,
      'licenseCategory': licenseCategory,
      'licenseIssuedDate': licenseIssuedDate?.toIso8601String(),
      'licenseExpiryDate': licenseExpiryDate?.toIso8601String(),
      'licensePhoto': licensePhoto,
      'completedRides': completedRides,
      'cancelledRides': cancelledRides,
      'workStartDate': workStartDate.toIso8601String(),
      'isActive': isActive,
      'receiveNotifications': receiveNotifications,
      'profilePhoto': profilePhoto,
      'isOnline': isOnline,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  // Геттеры для отображения
  String get experienceText {
    final now = DateTime.now();
    final experience = now.difference(workStartDate);
    final years = experience.inDays ~/ 365;
    final months = (experience.inDays % 365) ~/ 30;

    if (years > 0) {
      return '$years лет${months > 0 ? ' $months мес.' : ''}';
    } else if (months > 0) {
      return '$months месяцев';
    } else {
      return '${experience.inDays} дней';
    }
  }

  String get totalRidesText {
    return '${completedRides + cancelledRides}';
  }

  String get successRateText {
    final total = completedRides + cancelledRides;
    if (total == 0) return '0%';
    final rate = (completedRides / total * 100).round();
    return '$rate%';
  }

  String get phoneFormatted {
    // Форматирование армянского номера
    if (phone.startsWith('+374')) {
      final number = phone.substring(4);
      if (number.length == 8) {
        return '+374 ${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}';
      }
    }
    return phone;
  }

  // Проверки состояния
  bool get hasPassportData {
    return passportNumber != null && passportIssuedBy != null;
  }

  bool get hasLicenseData {
    return licenseNumber != null && licenseCategory != null;
  }

  bool get isLicenseValid {
    if (licenseExpiryDate == null) return true;
    return licenseExpiryDate!.isAfter(DateTime.now());
  }

  String get statusText {
    if (!isActive) return 'Неактивен';
    if (isOnline) return 'В сети';
    return 'Не в сети';
  }

  Driver copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? passportNumber,
    String? passportIssuedBy,
    DateTime? passportIssuedDate,
    String? passportPhoto,
    String? licenseNumber,
    String? licenseCategory,
    DateTime? licenseIssuedDate,
    DateTime? licenseExpiryDate,
    String? licensePhoto,
    int? completedRides,
    int? cancelledRides,
    DateTime? workStartDate,
    bool? isActive,
    bool? receiveNotifications,
    String? profilePhoto,
    bool? isOnline,
    DateTime? lastActiveAt,
  }) {
    return Driver(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      passportNumber: passportNumber ?? this.passportNumber,
      passportIssuedBy: passportIssuedBy ?? this.passportIssuedBy,
      passportIssuedDate: passportIssuedDate ?? this.passportIssuedDate,
      passportPhoto: passportPhoto ?? this.passportPhoto,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseCategory: licenseCategory ?? this.licenseCategory,
      licenseIssuedDate: licenseIssuedDate ?? this.licenseIssuedDate,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      licensePhoto: licensePhoto ?? this.licensePhoto,
      completedRides: completedRides ?? this.completedRides,
      cancelledRides: cancelledRides ?? this.cancelledRides,
      workStartDate: workStartDate ?? this.workStartDate,
      isActive: isActive ?? this.isActive,
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      isOnline: isOnline ?? this.isOnline,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
