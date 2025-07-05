import 'package:ata_mobile/Screens/Auth/login.dart';
import 'package:ata_mobile/Screens/Dashboard/Attendance/AttendanceDashboard.dart';
import 'package:ata_mobile/Screens/Dashboard/Attendance/CheckIn.dart';
import 'package:ata_mobile/Screens/Dashboard/Department/showDepartment.dart';
import 'package:ata_mobile/Screens/Dashboard/Employee/EmployeeList.dart';
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
                    icon: Icons.person_add_outlined,
                    title: 'Add Employee',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeListScreen(postion: "EMP"),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.group_add_outlined,
                    title: 'Add Department',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DepartmentsListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.group_add_outlined,
                    title: 'Add HR',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeListScreen(postion: "HR"),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.group_add_outlined,
                    title: 'Add Manager',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeListScreen(postion: "Manager"),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.map_outlined,
                    title: 'Attendance Dashboard',
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
                ],
                const Divider(color: Colors.black26),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'Settings');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'Help & Support');
                  },
                ),
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

// Enhanced Home Screen with Task & Attendance Focus
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.yellow.shade50, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section with Time
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow.shade300, Colors.yellow.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.shade200.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ready to be productive today?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getCurrentTime(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getGreetingIcon(),
                      size: 35,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.task_alt,
                    title: 'My Tasks',
                    subtitle: '5 pending',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.access_time,
                    title: 'Check In',
                    subtitle: 'Start work',
                    color: Colors.green,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Today's Overview
            Text(
              'Today\'s Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.3,
              children: [
                _buildStatsCard(
                  icon: Icons.assignment_turned_in,
                  title: 'Completed',
                  value: '8',
                  subtitle: 'Tasks',
                  color: Colors.green,
                ),
                _buildStatsCard(
                  icon: Icons.pending_actions,
                  title: 'Pending',
                  value: '5',
                  subtitle: 'Tasks',
                  color: Colors.orange,
                ),
                _buildStatsCard(
                  icon: Icons.schedule,
                  title: 'Work Hours',
                  value: '7.5h',
                  subtitle: 'Today',
                  color: Colors.blue,
                ),
                _buildStatsCard(
                  icon: Icons.trending_up,
                  title: 'Productivity',
                  value: '92%',
                  subtitle: 'This week',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny;
    if (hour < 17) return Icons.wb_sunny_outlined;
    return Icons.nightlight_round;
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final weekday = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][now.weekday - 1];
    final month = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][now.month - 1];
    return '$weekday, $month ${now.day}, ${now.year}';
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '$title $subtitle',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Task Management Screen
class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.yellow.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          // Task Overview Cards
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildTaskOverviewCard(
                    'Total Tasks',
                    '24',
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTaskOverviewCard(
                    'Completed',
                    '18',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTaskOverviewCard(
                    'Pending',
                    '6',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.yellow.shade400,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'Overdue'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Task List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList('all'),
                _buildTaskList('active'),
                _buildTaskList('completed'),
                _buildTaskList('overdue'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskOverviewCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(String type) {
    final List<Map<String, dynamic>> tasks = _getTasksByType(type);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: task['priority_color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task['priority'],
                      style: TextStyle(
                        color: task['priority_color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: task['status_color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task['status'],
                      style: TextStyle(
                        color: task['status_color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                task['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    task['due_date'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.yellow.shade300,
                    child: Text(
                      task['assignee'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getTasksByType(String type) {
    final allTasks = [
      {
        'title': 'Complete Mobile App Design',
        'description': 'Finish the UI/UX design for the mobile application',
        'priority': 'High',
        'priority_color': Colors.red,
        'status': 'In Progress',
        'status_color': Colors.blue,
        'due_date': 'Dec 25, 2024',
        'assignee': 'JD',
      },
      {
        'title': 'API Integration',
        'description': 'Integrate REST APIs with the mobile app',
        'priority': 'Medium',
        'priority_color': Colors.orange,
        'status': 'Pending',
        'status_color': Colors.orange,
        'due_date': 'Dec 30, 2024',
        'assignee': 'AS',
      },
      {
        'title': 'Database Setup',
        'description': 'Setup and configure the database schema',
        'priority': 'High',
        'priority_color': Colors.red,
        'status': 'Completed',
        'status_color': Colors.green,
        'due_date': 'Dec 20, 2024',
        'assignee': 'MB',
      },
      {
        'title': 'Testing & QA',
        'description': 'Perform comprehensive testing of all features',
        'priority': 'Low',
        'priority_color': Colors.green,
        'status': 'Overdue',
        'status_color': Colors.red,
        'due_date': 'Dec 15, 2024',
        'assignee': 'SK',
      },
    ];

    switch (type) {
      case 'active':
        return allTasks
            .where((task) => task['status'] == 'In Progress')
            .toList();
      case 'completed':
        return allTasks.where((task) => task['status'] == 'Completed').toList();
      case 'overdue':
        return allTasks.where((task) => task['status'] == 'Overdue').toList();
      default:
        return allTasks;
    }
  }
}

// Profile Screen remains the same
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.yellow.shade300,
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'john.doe@email.com',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Profile Menu Items
          _buildProfileMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notification Settings',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade100,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.yellow.shade700),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.black54,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
