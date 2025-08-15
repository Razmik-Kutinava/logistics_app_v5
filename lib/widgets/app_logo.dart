import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final bool showText;
  final Color? textColor;
  final TextStyle? textStyle;

  const AppLogo({
    super.key,
    this.size,
    this.showText = true,
    this.textColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Увеличиваем размеры логотипа для лучшей видимости (для водителей 35+)
    final defaultSize = screenWidth < 400
        ? 120.0
        : screenWidth < 600
            ? 150.0
            : 180.0;
    final logoSize = size ?? defaultSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(logoSize * 0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(logoSize * 0.1),
            child: Image.asset(
              'assets/icons/logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback к иконке если логотип не найден
                return Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(logoSize * 0.1),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    size: logoSize * 0.6,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(height: logoSize * 0.15),
          Text(
            'Logistics App',
            style: textStyle ??
                Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor ?? Theme.of(context).primaryColor,
                      fontSize: screenWidth < 400
                          ? 28
                          : screenWidth < 600
                              ? 32
                              : 40,
                    ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class ResponsiveLogo extends StatelessWidget {
  final bool showText;
  final Color? textColor;

  const ResponsiveLogo({
    super.key,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final isMediumScreen = constraints.maxWidth < 600;

        double logoSize;
        double fontSize;

        if (isSmallScreen) {
          logoSize = 90.0; // Увеличено с 60 до 90
          fontSize = 24.0; // Увеличено с 20 до 24
        } else if (isMediumScreen) {
          logoSize = 120.0; // Увеличено с 80 до 120
          fontSize = 28.0; // Увеличено с 24 до 28
        } else {
          logoSize = 150.0; // Увеличено с 100 до 150
          fontSize = 36.0; // Увеличено с 28 до 36
        }

        return AppLogo(
          size: logoSize,
          showText: showText,
          textColor: textColor,
          textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor ?? Theme.of(context).primaryColor,
                fontSize: fontSize,
              ),
        );
      },
    );
  }
}
