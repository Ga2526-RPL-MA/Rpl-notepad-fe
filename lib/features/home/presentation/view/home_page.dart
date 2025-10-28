import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/mobile/mobile_layout.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/web/web_layout.dart';
import '../../../../core/widgets/menu_drawer.dart';
import '../viewmodel/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel _viewModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      drawer: !isWeb
          ? MenuDrawer(
              currentPage: _viewModel.currentPage,
              onPageChanged: (page) {
                setState(() {
                  _viewModel.changePage(page);
                });
              },
            )
          : null,
      body: GradientBackground(
        child: SafeArea(
          child: isWeb
              ? WebLayout(
                  screenHeight: screenHeight,
                  viewModel: _viewModel,
                  currentPage: _viewModel.currentPage,
                  onPageChanged: (page) {
                    setState(() {
                      _viewModel.changePage(page);
                    });
                  },
                )
              : MobileLayout(
                  screenHeight: screenHeight,
                  viewModel: _viewModel,
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
        ),
      ),
    );
  }
}
