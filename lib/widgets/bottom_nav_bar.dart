import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  // Base icon colors (default, unselected)
  final List<Color> iconColors = [
    Colors.blue, // Home
    Colors.green, // Create
    Colors.purple, // Profile
  ];

  // Brighter colors for selected state
  final List<Color> selectedColors = [
    Colors.blueAccent, // Home selected
    Colors.lightGreen, // Create selected
    Colors.deepPurpleAccent, // Profile selected
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor:
          selectedColors[currentIndex], // Label color matches selected icon
      unselectedItemColor: Colors.grey, // Unselected labels grey
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: currentIndex == 0 ? selectedColors[0] : iconColors[0],
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add,
            color: currentIndex == 1 ? selectedColors[1] : iconColors[1],
          ),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: currentIndex == 2 ? selectedColors[2] : iconColors[2],
          ),
          label: 'Profile',
        ),
      ],
      showUnselectedLabels: true,
    );
  }
}
