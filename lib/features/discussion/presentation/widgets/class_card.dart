import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String iconPath;
  final String className;
  final String classTime;
  final String classRoom;
  final Color cardBackgroundColor;
  final Color cardOutlineColor;

  const ClassCard({
    super.key,
    required this.iconPath,
    required this.className,
    required this.classTime,
    required this.classRoom,
    required this.cardBackgroundColor,
    required this.cardOutlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: cardOutlineColor, width: 1.15),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Image.asset(
              iconPath,
              width: 22,
              height: 22,
              color: cardOutlineColor,
            ),
            const SizedBox(width: 8),

            // Class Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    className,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Time and Room
                  Text(
                    '$classTime, $classRoom',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0XFF6D717F),
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Button Lihat
                  Text(
                    'Lihat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cardOutlineColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
