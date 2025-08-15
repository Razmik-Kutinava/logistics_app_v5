import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistics_app/utils/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedCode;
  bool isScanning = true;
  bool hasPermission = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // В реальном приложении здесь будет проверка разрешений
    setState(() {
      hasPermission = true;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanning && capture.barcodes.isNotEmpty) {
      final String? code = capture.barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          scannedCode = code;
          isScanning = false;
        });

        // Vibrate on scan (в реальном приложении)
        _onCodeScanned(code);
      }
    }
  }

  void _onCodeScanned(String code) {
    // Логика обработки отсканированного QR-кода
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundWhite,
        title: Text(
          'QR-код отсканирован',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Код товара:',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDarkBlue,
              ),
            ),
            SizedBox(height: AppTheme.getResponsivePadding(context, 8.0) * 0.5),
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.all(AppTheme.getResponsivePadding(context, 16.0)),
              decoration: BoxDecoration(
                color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryDarkBlue.withOpacity(0.3),
                ),
              ),
              child: Text(
                code,
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 16),
                  fontFamily: 'monospace',
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppTheme.getResponsivePadding(context, 16.0)),
            Text(
              'Товар будет автоматически добавлен в базу данных и распределен по водителям.',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 14),
                color: AppTheme.textDark.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetScanning();
            },
            child: Text(
              'Сканировать еще',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                color: AppTheme.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              foregroundColor: AppTheme.backgroundWhite,
              minimumSize: Size(120, AppTheme.getButtonHeight(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Готово',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetScanning() {
    setState(() {
      scannedCode = null;
      isScanning = true;
    });
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
    });
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
    cameraController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        appBar: AppBar(
          title: Text(
            'QR Сканер',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: AppTheme.backgroundWhite,
            ),
          ),
          backgroundColor: AppTheme.primaryDarkBlue,
          foregroundColor: AppTheme.backgroundWhite,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: AppTheme.getIconSize(context, 24.0),
              color: AppTheme.backgroundWhite,
            ),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: AppTheme.getIconSize(context, 48.0) * 3,
                color: AppTheme.primaryDarkBlue.withOpacity(0.5),
              ),
              SizedBox(height: AppTheme.getResponsivePadding(context, 16.0)),
              Text(
                'Нет доступа к камере',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(
                  height: AppTheme.getResponsivePadding(context, 8.0) * 0.5),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getResponsivePadding(context, 16.0) * 2,
                ),
                child: Text(
                  'Для сканирования QR-кодов товаров необходимо разрешить доступ к камере в настройках приложения.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 16),
                    color: AppTheme.textDark.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(
                  height: AppTheme.getResponsivePadding(context, 16.0) * 2),
              ElevatedButton(
                onPressed: _checkPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: AppTheme.backgroundWhite,
                  minimumSize: Size(200, AppTheme.getButtonHeight(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Проверить снова',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryDarkBlue,
      appBar: AppBar(
        title: Text(
          'QR Сканер товаров',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: AppTheme.backgroundWhite,
          ),
        ),
        backgroundColor: AppTheme.primaryDarkBlue,
        foregroundColor: AppTheme.backgroundWhite,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: AppTheme.getIconSize(context, 24.0),
            color: AppTheme.backgroundWhite,
          ),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          // Flash toggle
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              size: AppTheme.getIconSize(context, 24.0),
              color: AppTheme.backgroundWhite,
            ),
            onPressed: _toggleFlash,
          ),
          // Camera switch
          if (!kIsWeb) // Camera switching не работает на web
            IconButton(
              icon: Icon(
                Icons.cameraswitch,
                size: AppTheme.getIconSize(context, 24.0),
                color: AppTheme.backgroundWhite,
              ),
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: Column(
        children: [
          // Scanner area
          Expanded(
            flex: 4,
            child: Container(
              margin:
                  EdgeInsets.all(AppTheme.getResponsivePadding(context, 16.0)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentOrange,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
              ),
            ),
          ),

          // Instructions and status
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding:
                  EdgeInsets.all(AppTheme.getResponsivePadding(context, 16.0)),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Scanner status
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getResponsivePadding(context, 16.0),
                      vertical:
                          AppTheme.getResponsivePadding(context, 8.0) * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: isScanning
                          ? AppTheme.statusGreen.withOpacity(0.1)
                          : AppTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isScanning
                            ? AppTheme.statusGreen.withOpacity(0.3)
                            : AppTheme.accentOrange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isScanning
                              ? Icons.qr_code_scanner
                              : Icons.check_circle,
                          size: AppTheme.getIconSize(context, 20.0) * 0.8,
                          color: isScanning
                              ? AppTheme.statusGreen
                              : AppTheme.accentOrange,
                        ),
                        SizedBox(
                            width: AppTheme.getResponsivePadding(context, 8.0) *
                                0.5),
                        Text(
                          isScanning ? 'Готов к сканированию' : 'QR-код найден',
                          style: TextStyle(
                            fontSize:
                                AppTheme.getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: isScanning
                                ? AppTheme.statusGreen
                                : AppTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Instructions
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getResponsivePadding(context, 16.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Наведите камеру на QR-код товара',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                AppTheme.getResponsiveFontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(
                            height:
                                AppTheme.getResponsivePadding(context, 8.0) *
                                    0.5),
                        Text(
                          'Убедитесь, что QR-код полностью помещается в рамке камеры для точного сканирования',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                AppTheme.getResponsiveFontSize(context, 14),
                            color: AppTheme.textDark.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reset button (if scanned)
                  if (!isScanning)
                    ElevatedButton(
                      onPressed: _resetScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDarkBlue,
                        foregroundColor: AppTheme.backgroundWhite,
                        minimumSize:
                            Size(200, AppTheme.getButtonHeight(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Сканировать еще раз',
                        style: TextStyle(
                          fontSize: AppTheme.getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
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
}
