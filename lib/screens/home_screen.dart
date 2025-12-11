import 'package:absensi_app/screens/absensi_screen.dart';
import 'package:absensi_app/screens/beranda_screen.dart';
import 'package:absensi_app/screens/profile_screen.dart';
import 'package:absensi_app/screens/ubah_akun_screen.dart';
import 'package:absensi_app/screens/setting_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    BerandaScreen(),
    ProfileScreen(),
    AbsensiScreen(), 
    UbahAkunScreen(), 
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // Bottom navigation
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bottom bar
                Container(
                  height: 60, // tinggi BottomAppBar
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Beranda
                      GestureDetector(
                        onTap: () => _onItemTapped(0),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0), // hapus margin bawah
                          child: Icon(
                            Icons.home,
                            size: 25,
                            color: _selectedIndex == 0 ? Colors.red : Color(0xFF555555),
                          ),
                        ),
                      ),

                      // Profil
                      GestureDetector(
                        onTap: () => _onItemTapped(1),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Icon(
                            Icons.account_circle,
                            size: 25,
                            color: _selectedIndex == 1 ? Colors.red : Color(0xFF555555),
                          ),
                        ),
                      ),

                      SizedBox(width: 60), // space untuk Absensi

                      // Password
                      GestureDetector(
                        onTap: () => _onItemTapped(3),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Icon(
                            Icons.key_rounded,
                            size: 25,
                            color: _selectedIndex == 3 ? Colors.red : Color(0xFF555555),
                          ),
                        ),
                      ),

                      // Pengaturan
                      GestureDetector(
                        onTap: () => _onItemTapped(4),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Icon(
                            Icons.settings,
                            size: 25,
                            color: _selectedIndex == 4 ? Colors.red : Color(0xFF555555),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Absensi menjorok
                Positioned(
                  top: -20, // menjorok ke atas
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _onItemTapped(2),
                    child: Center(
                      child: Image.asset(
                        'assets/icon/logo.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
