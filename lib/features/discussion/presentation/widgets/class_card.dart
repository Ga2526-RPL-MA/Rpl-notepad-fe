import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String iconPath;
  final String className;
  final String classTime;
  final String classRoom;
  final Color cardBackgroundColor;
  final Color cardOutlineColor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool showEditIcon;

  const ClassCard({
    super.key,
    required this.iconPath,
    required this.className,
    required this.classTime,
    required this.classRoom,
    required this.cardBackgroundColor,
    required this.cardOutlineColor,
    this.onTap,
    this.onEdit,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: cardOutlineColor, width: 1.15),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Image.asset(
                iconPath,
                width: 20,
                height: 20,
                color: cardOutlineColor,
              ),
              const SizedBox(width: 10),

              // Class Info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with edit icon
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            className,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        if (showEditIcon && onEdit != null)
                          GestureDetector(
                            onTap: () {
                              onEdit!();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: cardOutlineColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Time and Room
                    Text(
                      '$classTime, $classRoom',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0XFF6D717F),
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Button Lihat
                    onTap != null
                        ? Text(
                            'Lihat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cardOutlineColor,
                              fontFamily: 'Inter',
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
