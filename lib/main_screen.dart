import 'package:flutter/material.dart';
import 'package:jomaboi/main_screen/home_screen.dart';
import 'package:jomaboi/pages/accounts_page.dart';
import 'package:jomaboi/pages/categories_page.dart';
import 'package:jomaboi/pages/home_page.dart';
import 'package:jomaboi/pages/settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of pages to be displayed in the IndexedStack
  final List<Widget> _pages = [
    const HomePage(),
    const AccountsPage(),
    const CategoriesPage(),
    const HomeScreen(), // Existing Co-Operative implementation
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Required for more than 3 items
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Co-Operative',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}