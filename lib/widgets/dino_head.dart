import 'package:flutter/material.dart';

/// Показывает голову и плечи выбранного динозавра.
/// Используется существующий neutral_small PNG, поэтому
/// отдельные изображения голов не нужны.
class DinoHead extends StatelessWidget {
  final String asset;
  final double size;
  final BorderRadius borderRadius;
  final Color backgroundColor;

  const DinoHead({
    super.key,
    required this.asset,
    this.size = 76,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.backgroundColor = const Color(0xFFDDF3D4),
  });

  @override
  Widget build(BuildContext context) {
    // Область головы + плеч исходного PNG 1536x1024.
    // Ноги и большая часть тела остаются за пределами ClipRect.
    const cropLeft = 70.0;
    const cropTop = 390.0;
    const cropWidth = 450.0;
    const cropHeight = 430.0;

    final scale = size / cropHeight;
    final imageWidth = 1536 * scale;
    final imageHeight = 1024 * scale;

    final left = -cropLeft * scale;
    final top = -cropTop * scale;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: left,
            top: top,
            width: imageWidth,
            height: imageHeight,
            child: Image.asset(
              asset,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) {
                return const Center(
                  child: Text(
                    '🦕',
                    style: TextStyle(fontSize: 36),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
