import 'package:flutter/material.dart';

class Bottombar extends StatelessWidget {
  final int currentIndex;

  const Bottombar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Do nothing if already on the page

    // Navigate to the correct page based on the index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/courses');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/forum');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/tutors');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex > 4 ? 0 : currentIndex,
      
      onTap: (index) => _onItemTapped(context, index), // Handle navigation inside
      selectedItemColor: Color(0xFF2D5DA1),
      unselectedItemColor: const Color.fromARGB(255, 96, 96, 96),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      items: [
        BottomNavigationBarItem(
          icon: currentIndex == 0 ? const Icon(Icons.home) : const Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 1 ? const Icon(Icons.auto_stories) : const Icon(Icons.auto_stories_outlined),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 2 ? const Icon(Icons.forum) : const Icon(Icons.forum_outlined),
          label: 'Forum',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 3 ? const Icon(Icons.group) : const Icon(Icons.group_outlined),
          label: 'Tutor',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 4 ? const Icon(Icons.person) : const Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
