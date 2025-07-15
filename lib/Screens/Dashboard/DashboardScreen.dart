import 'package:ata_mobile/Screens/Auth/login.dart';
import 'package:ata_mobile/Screens/Dashboard/Attendance/AttendanceDashboard.dart';
import 'package:ata_mobile/Screens/Dashboard/Attendance/CheckIn.dart';
import 'package:ata_mobile/Screens/Dashboard/Department/showDepartment.dart';
import 'package:ata_mobile/Screens/Dashboard/Employee/EmployeeList.dart';
import 'package:ata_mobile/Screens/Dashboard/Home/HomeScreen.dart';
import 'package:ata_mobile/Screens/Dashboard/Office/ShowOffice.dart';
import 'package:ata_mobile/Screens/Dashboard/Profile/profilescreen.dart';
import 'package:ata_mobile/Screens/Dashboard/Task/TaskScreen.dart';
import 'package:ata_mobile/Screens/Dashboard/Employee/UserManagementScreen.dart';
import 'package:ata_mobile/Utilities/SharedPrefManager.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String userName;
  late String userEmail;
  late String userProfileImage;
  late int userId;
  late String userRole;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _loadUserData() async {
    userName =
        await SharedPrefManager().getString(
          SharedPrefManager.userFullNameKey,
        ) ??
        '';
    userEmail =
        await SharedPrefManager().getString(SharedPrefManager.userEmailKey) ??
        '';
    userProfileImage =
        await SharedPrefManager().getString(
          SharedPrefManager.userProfileImageKey,
        ) ??
        '';
    userId = await SharedPrefManager().getInt(SharedPrefManager.userIdKey) ?? 0;
    userRole =
        await SharedPrefManager().getString(SharedPrefManager.userRoleKey) ??
        '';
    setState(() {});
  }

  final List<Widget> _screens = [
    HomeScreen(),
    TaskManagementScreen(),
    ProfileScreen(),
  ];

  final List<String> _screenTitles = ['Dashboard', 'Tasks', 'Profile'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _screenTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.yellow.shade400,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.black),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
          ),
        ],
      ),
      drawer: _buildSideDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.shade200.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.yellow.shade700,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_outlined),
              activeIcon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideDrawer() {
    return FutureBuilder<String?>(
      future: SharedPrefManager().getString(SharedPrefManager.userRoleKey),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        return Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.yellow.shade300,
                  Colors.yellow.shade100,
                  Colors.white,
                ],
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.yellow.shade400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.network(
                            userProfileImage,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.yellow.shade700,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                if (role == 'ROLE_EMPLOYEE') ...[
                  _buildDrawerItem(
                    icon: Icons.access_time_outlined,
                    title: 'Attendance',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeAttendanceScreen(
                            employeeId: userId,
                            employeeName: userName,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                if (role == 'ROLE_ADMIN') ...[
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'Employee',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserManagementScreen(),
                        ),
                      );
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.location_on_outlined,
                    title: 'Attendance',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AttendanceDashboard(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.work_outline,
                    title: 'Office',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShowOffice(),
                        ),
                      );
                    },
                  ),
                ],
                const Divider(color: Colors.black26),
                _buildDrawerItem(
                  icon: Icons.logout_outlined,
                  title: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.yellow.shade600,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout', style: TextStyle(color: Colors.black)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black54),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade400,
              ),
              onPressed: () {
                SharedPrefManager().clearAll();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
