//
// Main bottom navigation bar for app-wide navigation.
// Handles switching between Home, Reports, Report, and Profile.
//

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../pages/account.dart';
import '../pages/home.dart';
import '../pages/report.dart';
import '../pages/reports.dart';

// Bottom navigation bar widget
class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

// State for navigation logic and UI
class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Color definitions for navigation bar
    const Color selectedColor = Color(0xFF04274B);
    const Color unselectedColor = Colors.grey;

    // List of pages for navigation
    final List<Widget> pages = [
      const HomePage(),
      const ReportPage(),
      const ReportsPage(),
      const AccountPage(),
    ];

    final appLoc = AppLocalizations.of(context);

    // Scaffold with navigation bar and current page
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[currentPageIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            // Navigation bar label styles
            labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
              Set<MaterialState> states,
            ) {
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(color: selectedColor);
              }
              return const TextStyle(color: unselectedColor);
            }),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: selectedColor.withOpacity(0.1),
            // Handle navigation selection
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            // Navigation destinations
            destinations: <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home, color: selectedColor),
                icon: Icon(Icons.home_outlined, color: unselectedColor),
                label: appLoc.translate('Home'),
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.report, color: selectedColor),
                icon: Icon(Icons.report_outlined, color: unselectedColor),
                label: appLoc.translate('Report'),
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.insert_drive_file,
                  color: selectedColor,
                ),
                icon: Icon(
                  Icons.insert_drive_file_outlined,
                  color: unselectedColor,
                ),
                label: appLoc.translate('Reports'),
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person, color: selectedColor),
                icon: Icon(Icons.person_outline, color: unselectedColor),
                label: appLoc.translate('Profile'),
              ),
            ],
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}
