import 'package:flutter/material.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../../../../../../core/widgets/menu_drawer.dart';
import '../../viewmodel/home_viewmodel.dart';
import 'web_header.dart';
import 'web_content_area.dart';

class WebLayout extends StatelessWidget {
  final double screenHeight;
  final HomeViewModel viewModel;
  final Function(String) onPageChanged;
  final String currentPage;

  const WebLayout({
    super.key,
    required this.screenHeight,
    required this.viewModel,
    required this.onPageChanged,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar
        MenuDrawer(
          currentPage: currentPage,
          onPageChanged: onPageChanged,
        ),
        const SizedBox(width: 20),
        
        // Main content
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: WebHeader(viewModel: viewModel),
              ),
              const SizedBox(height: 20),
              
              // Content Area
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    CustomCard(
                      color: Colors.white,
                      width: double.infinity,
                      height: screenHeight * 0.81, 
                      child: WebContentArea(viewModel: viewModel),
                    ),
                    const SizedBox(height: 20),
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
