import 'dart:ui';
import 'package:flutter/material.dart';

//  Black Overlay 
class BlackBlurOverlay extends StatelessWidget {
  final double height;
  final double blurSigma;
  final double opacity;

  const BlackBlurOverlay({
    super.key,
    required this.height,
    this.blurSigma = 8,
    this.opacity = 0.58,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          height: height,
          color: Colors.black.withOpacity(opacity),
        ),
      ),
    );
  }
}
