import 'package:flutter/material.dart';

class CoinIcon extends StatelessWidget {
  final double size;

  const CoinIcon({
    super.key,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/coin.png',
        fit: BoxFit.contain,
      ),
    );
  }
}