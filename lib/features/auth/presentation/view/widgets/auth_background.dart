import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const BackgroundImage({
    super.key,
    this.imagePath = 'assets/images/auth-bg.png',
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        imagePath,
        fit: fit,
      ),
    );
  }
}
