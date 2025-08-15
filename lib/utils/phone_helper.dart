import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:logistics_app/utils/app_theme.dart';

class PhoneHelper {
  /// Совершить звонок по номеру телефона
  static Future<bool> makeCall(String phoneNumber) async {
    try {
      final cleanPhone = _cleanPhoneNumber(phoneNumber);
      final uri = Uri.parse('tel:$cleanPhone');

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Отправить SMS
  static Future<bool> sendSMS(String phoneNumber, {String? message}) async {
    try {
      final cleanPhone = _cleanPhoneNumber(phoneNumber);
      String uri = 'sms:$cleanPhone';

      if (message != null && message.isNotEmpty) {
        uri += '?body=${Uri.encodeComponent(message)}';
      }

      final smsUri = Uri.parse(uri);

      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Показать диалог с вариантами связи
  static void showContactDialog(
    BuildContext context,
    String phoneNumber,
    String customerName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.phone,
              color: AppTheme.primaryDarkBlue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Связь с клиентом',
                style: TextStyle(
                  color: AppTheme.primaryDarkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatPhoneNumber(phoneNumber),
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textDark.withOpacity(0.8),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Выберите способ связи:',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textDark.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: AppTheme.textDark.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final success = await sendSMS(
                phoneNumber,
                message:
                    'Здравствуйте! Это ваш водитель из CIO Logistics. Я направляюсь к вам с заказом.',
              );
              if (context.mounted) {
                _showResultSnackBar(
                    context, success, 'SMS отправлено', 'Ошибка отправки SMS');
              }
            },
            icon: Icon(
              Icons.message,
              color: AppTheme.accentOrange,
            ),
            label: Text(
              'SMS',
              style: TextStyle(
                color: AppTheme.accentOrange,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final success = await makeCall(phoneNumber);
              if (context.mounted) {
                _showResultSnackBar(context, success, 'Звонок инициирован',
                    'Ошибка при звонке');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusGreen,
              foregroundColor: AppTheme.textLight,
            ),
            icon: Icon(Icons.call),
            label: Text(
              'Позвонить',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Очистить номер телефона от лишних символов
  static String _cleanPhoneNumber(String phoneNumber) {
    // Удаляем все символы кроме цифр и +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Если номер начинается с 8, заменяем на +7
    if (cleaned.startsWith('8') && cleaned.length == 11) {
      cleaned = '+7${cleaned.substring(1)}';
    }

    // Если номер начинается с 7, добавляем +
    if (cleaned.startsWith('7') && cleaned.length == 11) {
      cleaned = '+$cleaned';
    }

    // Если номер армянский без кода страны
    if (cleaned.length == 8 && !cleaned.startsWith('+')) {
      cleaned = '+374$cleaned';
    }

    return cleaned;
  }

  /// Форматировать номер телефона для отображения
  static String formatPhoneNumber(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);

    // Армянский номер +374XXXXXXXX
    if (cleaned.startsWith('+374') && cleaned.length == 12) {
      final number = cleaned.substring(4);
      return '+374 ${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}';
    }

    // Российский номер +7XXXXXXXXXX
    if (cleaned.startsWith('+7') && cleaned.length == 12) {
      final number = cleaned.substring(2);
      return '+7 ${number.substring(0, 3)} ${number.substring(3, 6)}-${number.substring(6, 8)}-${number.substring(8)}';
    }

    return phoneNumber; // Возвращаем как есть, если не удалось распознать формат
  }

  /// Проверить валидность номера телефона
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);

    // Армянские номера
    if (cleaned.startsWith('+374') && cleaned.length == 12) {
      return true;
    }

    // Российские номера
    if (cleaned.startsWith('+7') && cleaned.length == 12) {
      return true;
    }

    // Другие международные номера (базовая проверка)
    if (cleaned.startsWith('+') &&
        cleaned.length >= 10 &&
        cleaned.length <= 15) {
      return true;
    }

    return false;
  }

  /// Показать результат операции
  static void _showResultSnackBar(
    BuildContext context,
    bool success,
    String successMessage,
    String errorMessage,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? successMessage : errorMessage,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: success ? AppTheme.statusGreen : AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: success ? 2 : 3),
      ),
    );
  }

  /// Получить иконку для типа номера
  static IconData getPhoneIcon(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);

    if (cleaned.startsWith('+374')) {
      return Icons.phone; // Армянский номер
    } else if (cleaned.startsWith('+7')) {
      return Icons.phone; // Российский номер
    } else {
      return Icons.phone; // Международный номер
    }
  }

  /// Получить описание типа номера
  static String getPhoneType(String phoneNumber) {
    final cleaned = _cleanPhoneNumber(phoneNumber);

    if (cleaned.startsWith('+374')) {
      return 'Армения';
    } else if (cleaned.startsWith('+7')) {
      return 'Россия';
    } else if (cleaned.startsWith('+')) {
      return 'Международный';
    } else {
      return 'Местный';
    }
  }
}
