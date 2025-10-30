import 'package:flutter/material.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../../viewmodel/home_viewmodel.dart';
import 'mobile_header.dart';
import 'mobile_content_area.dart';

class MobileLayout extends StatelessWidget {
  final double screenHeight;
  final HomeViewModel viewModel;
  final VoidCallback onMenuPressed;

  const MobileLayout({
    super.key,
    required this.screenHeight,
    required this.viewModel,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              CustomCard(
                color: Colors.white,
                height: screenHeight * 0.9,
                child: Column(
                  children: [
                    MobileHeader(onMenuPressed: onMenuPressed),
                    MobileContentArea(
                      viewModel: viewModel,
                      isWeb: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
