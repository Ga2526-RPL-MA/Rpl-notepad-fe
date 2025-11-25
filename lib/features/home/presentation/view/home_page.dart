import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';
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

    // Setup toast callback
    _viewModel.onShowToast = (title, message, type) {
      if (mounted) {
        showAppToast(context, title: title, message: message, type: type);
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRouteArguments();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleRouteArguments();
  }

  void _handleRouteArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['tab'] == 'completed') {
      setState(() {
        _viewModel.changePage('tugas_selesai');
      });
    } else if (_viewModel.currentPage.isEmpty) {
      setState(() {
        _viewModel.changePage('beranda');
      });
    }
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
              onPageChanged: (page) async {
                if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop();
                  await Future.delayed(const Duration(milliseconds: 200));
                }
                setState(() {
                  _viewModel.changePage(page);
                });
                if (page == 'diskusi') {
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/discussion');
                }
              },
            )
          : null,
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: AnimatedBuilder(
                animation: _viewModel,
                builder: (context, _) {
                  return isWeb
                      ? WebLayout(
                          screenHeight: screenHeight,
                          viewModel: _viewModel,
                          currentPage: _viewModel.currentPage,
                          onPageChanged: (page) {
                            setState(() {
                              _viewModel.changePage(page);
                            });
                            if (page == 'diskusi') {
                              Navigator.pushNamed(context, '/discussion');
                            }
                          },
                        )
                      : MobileLayout(
                          screenHeight: screenHeight,
                          viewModel: _viewModel,
                          onMenuPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        );
                },
              ),
            ),
            AnimatedBuilder(
              animation: _viewModel,
              builder: (context, _) => _viewModel.isLoading
                  ? const LoadingOverlay()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
