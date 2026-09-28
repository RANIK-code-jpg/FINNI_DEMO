import 'package:flutter/material.dart';

class CoinIcon extends StatelessWidget {
  final double size;

  const CoinIcon({
    super.key,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    const scale = 1.42;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            'assets/coin.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class CoinAmount extends StatelessWidget {
  final String amount;
  final double iconSize;
  final TextStyle? textStyle;
  final MainAxisAlignment alignment;

  const CoinAmount({
    super.key,
    required this.amount,
    this.iconSize = 20,
    this.textStyle,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          amount,
          style: textStyle,
        ),
        const SizedBox(width: 4),
        CoinIcon(size: iconSize),
      ],
    );
  }
}

class CoinText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? iconSize;

  const CoinText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = baseStyle.fontSize ?? 14;

    final resolvedIconSize =
        iconSize ?? (fontSize * 1.18).clamp(14.0, 30.0).toDouble();

    final parts = text.split('🪙');
    final spans = <InlineSpan>[];

    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(
          TextSpan(
            text: parts[i],
            style: baseStyle,
          ),
        );
      }

      if (i < parts.length - 1) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CoinIcon(size: resolvedIconSize),
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}