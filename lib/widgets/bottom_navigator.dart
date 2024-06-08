// Flutter imports:
import 'package:flutter/material.dart';

class CustomBottomNavigator extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigator({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF3D5A6C),
      unselectedItemColor: const Color(0xFFDBDBDB),
      type: BottomNavigationBarType.fixed,
      onTap: (newIndex) {
        if (currentIndex == newIndex) {
          return;
        }
        switch (newIndex) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/trips');
            break;
          default:
            Navigator.pushReplacementNamed(
                context, '/home'); // Default fallback
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flight),
          label: 'Trips',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
