import 'package:flutter/material.dart';
import '../widgets/class_card.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../../core/widgets/custom_card.dart';

class DiscussionPage extends StatelessWidget {
  const DiscussionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Kelas Diskusi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final isGreenTheme = index % 2 == 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ClassCard(
                          iconPath: 'assets/icons/star_icon.png',
                          className: 'Kelas ${index + 1}',
                          classDescription: 'Deskripsi kelas ${index + 1}',
                          cardBackgroundColor: isGreenTheme
                              ? const Color(0xFFECF8EF)
                              : const Color(0xFFE6F4FF),
                          cardOutlineColor: isGreenTheme
                              ? const Color(0xFF43B75D)
                              : const Color(0xFF0095FF),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
