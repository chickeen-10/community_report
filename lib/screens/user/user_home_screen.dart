import 'package:flutter/material.dart';
import 'package:community_report/models/user_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'home_tab.dart';
import 'create_tab.dart';
import 'profile_tab.dart';

class UserHomeScreen extends StatefulWidget {
  final UserModel user;

  const UserHomeScreen({super.key, required this.user});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<HomeTabState> homeTabKey = GlobalKey<HomeTabState>();

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        _currentIndex == 0
            ? "Community Reports"
            : _currentIndex == 1
                ? "Create Reports"
                : "Profile",
      ),
      backgroundColor: _currentIndex == 2 ? Colors.grey[100] : null,
      foregroundColor: Colors.black,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          color: Colors.grey[300],
          height: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeTab(
        key: homeTabKey,
        loggedInUser: widget.user.email,
        loggedInRole: widget.user.role,
      ),
      CreateReportScreen(
        loggedInUser: widget.user.email,
        onReportAdded: () {
          homeTabKey.currentState?.refreshReports();
          setState(() => _currentIndex = 0);
        },
      ),
      ProfileTab(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
