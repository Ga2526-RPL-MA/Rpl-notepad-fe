import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double cornerRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.width = 370,
    this.height = 571,
    this.cornerRadius = 13.43,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
