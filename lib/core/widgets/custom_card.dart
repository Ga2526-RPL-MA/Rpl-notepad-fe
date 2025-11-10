import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double cornerRadius;
  final Color? color;
  final bool flexible;
  final double? minHeight;

  const CustomCard({
    super.key,
    required this.child,
    this.width = 370,
    this.height = 571,
    this.cornerRadius = 13.43,
    this.color,
    this.flexible = false,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color ?? Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (flexible) {
      if ((minHeight ?? 0) > 0) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight!),
          child: card,
        );
      }
      return card;
    }

    return SizedBox(
      width: width,
      height: height,
      child: card,
    );
  }
}
