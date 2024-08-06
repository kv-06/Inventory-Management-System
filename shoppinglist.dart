import 'package:flutter/material.dart';
import 'package:invent/shopping_list_page.dart';

import 'main_page.dart';

void main() => runApp(const NavigationBarApp(userId: 1,));

class NavigationBarApp extends StatelessWidget {
  final int userId;
  const NavigationBarApp({super.key,required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: NavigationExample(userId: userId,),
    );
  }
}

class NavigationExample extends StatefulWidget {

  final int userId;
  const NavigationExample({super.key,required this.userId});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_sharp),
            label: 'Shopping List',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        HomePage(userId: 1),

        /// Notifications page
        ShoppingListPage(userId: 1,),
      ][currentPageIndex],
    );
  }
}