import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/add_task_modal.dart';
import '../../../../core/widgets/menu_drawer.dart';
import '../viewmodel/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DashboardViewModel _viewModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuDrawer(
        currentPage: _viewModel.currentPage,
        onPageChanged: (page) {
          setState(() {
            _viewModel.changePage(page);
          });
        },
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 8),
                    CustomCard(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Menu Button
                                GestureDetector(
                                  onTap: () {
                                    _scaffoldKey.currentState?.openDrawer();
                                  },
                                  child: Image.asset(
                                    'assets/icon/menu-icon.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                // Profile
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Andina Pasha Rahmania',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '505323101@student.its.ac.id',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[300],
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 20,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Scrollable Content
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              children: [
                                // Search bar
                                const CustomSearchBar(),
                                const SizedBox(height: 24),
                                // Title Tugas Kuliah
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: const Text(
                                    'Tugas Kuliah',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // List Tugas
                                ..._viewModel.tugas
                                    .map(
                                      (item) => TaskItemWidget(
                                        title: item['title'] as String,
                                        status: item['status'] as String,
                                      ),
                                    )
                                    .toList(),
                                const SizedBox(height: 48),
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 134,
                                    height: 38,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            return AddTaskModal(
                                              parentContext: context,
                                              onSave:
                                                  (
                                                    title,
                                                    status,
                                                    deadline,
                                                    description,
                                                  ) {
                                                    setState(() {
                                                      _viewModel.addTask(
                                                        title,
                                                        status,
                                                        deadline,
                                                        description,
                                                      );
                                                    });
                                                  },
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.add,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Tambah',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
