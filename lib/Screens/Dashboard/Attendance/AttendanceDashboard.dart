import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
      ),
      home: const AttendanceDashboard(),
    );
  }
}

class Department {
  final String name;
  final int totalEmployees;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final double attendanceRate;
  final Color color;

  Department({
    required this.name,
    required this.totalEmployees,
    required this.presentToday,
    required this.absentToday,
    required this.lateToday,
    required this.attendanceRate,
    required this.color,
  });
}

class AttendanceRecord {
  final String employeeName;
  final String department;
  final String checkIn;
  final String status;
  final String profilePic;

  AttendanceRecord({
    required this.employeeName,
    required this.department,
    required this.checkIn,
    required this.status,
    required this.profilePic,
  });
}

class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({super.key});

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _chartController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _chartAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);
  static const Color cardWhite = Color(0xFFFAFAFA);

  String selectedPeriod = 'Today';
  final List<String> periods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
  ];

  final List<Department> departments = [
    Department(
      name: 'Engineering',
      totalEmployees: 45,
      presentToday: 42,
      absentToday: 2,
      lateToday: 1,
      attendanceRate: 93.3,
      color: const Color(0xFF4CAF50),
    ),
    Department(
      name: 'Design',
      totalEmployees: 18,
      presentToday: 16,
      absentToday: 1,
      lateToday: 1,
      attendanceRate: 88.9,
      color: const Color(0xFF2196F3),
    ),
    Department(
      name: 'Marketing',
      totalEmployees: 25,
      presentToday: 23,
      absentToday: 2,
      lateToday: 0,
      attendanceRate: 92.0,
      color: const Color(0xFF9C27B0),
    ),
    Department(
      name: 'Sales',
      totalEmployees: 32,
      presentToday: 28,
      absentToday: 3,
      lateToday: 1,
      attendanceRate: 87.5,
      color: const Color(0xFFFF5722),
    ),
  ];

  final List<AttendanceRecord> recentRecords = [
    AttendanceRecord(
      employeeName: 'Alice Johnson',
      department: 'Engineering',
      checkIn: '09:15 AM',
      status: 'Present',
      profilePic: 'https://i.pravatar.cc/150?img=1',
    ),
    AttendanceRecord(
      employeeName: 'Robert Smith',
      department: 'Design',
      checkIn: '09:45 AM',
      status: 'Late',
      profilePic: 'https://i.pravatar.cc/150?img=2',
    ),
    AttendanceRecord(
      employeeName: 'Emily Chen',
      department: 'Marketing',
      checkIn: '08:55 AM',
      status: 'Present',
      profilePic: 'https://i.pravatar.cc/150?img=3',
    ),
    AttendanceRecord(
      employeeName: 'Michael Rodriguez',
      department: 'Sales',
      checkIn: '--',
      status: 'Absent',
      profilePic: 'https://i.pravatar.cc/150?img=4',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.elasticOut),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlack,
      body: CustomScrollView(
        slivers: [
          _buildAnimatedHeader(),
          _buildPeriodSelector(),
          _buildOverviewCards(),
          _buildDepartmentAnalytics(),
          _buildAttendanceChart(),
          _buildRecentActivity(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAnimatedHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: darkBlack,
      flexibleSpace: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryYellow.withOpacity(0.9),
                    darkYellow.withOpacity(0.8),
                  ],
                ),
              ),
              child: Transform.scale(
                scale: _headerAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.analytics_rounded,
                        size: 60 * _headerAnimation.value,
                        color: darkBlack,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Attendance Dashboard',
                        style: TextStyle(
                          fontSize: 28 * _headerAnimation.value,
                          fontWeight: FontWeight.bold,
                          color: darkBlack,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Monitor team attendance in real-time',
                        style: TextStyle(
                          fontSize: 16 * _headerAnimation.value,
                          color: darkBlack.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: lightBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryYellow.withOpacity(0.3)),
        ),
        child: Row(
          children: periods.map((period) {
            final isSelected = selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPeriod = period;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryYellow : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? darkBlack : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Container(
            height: 130, // Increased from 120 to 130
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: _buildOverviewCard(
                        'Total Present',
                        '109',
                        Icons.check_circle_rounded,
                        const Color(0xFF4CAF50),
                        '91.6%',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: _buildOverviewCard(
                        'Total Absent',
                        '8',
                        Icons.cancel_rounded,
                        Colors.red,
                        '6.7%',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: _buildOverviewCard(
                        'Late Arrivals',
                        '3',
                        Icons.access_time_rounded,
                        Colors.orange,
                        '2.5%',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String count,
    IconData icon,
    Color color,
    String percentage,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, lightYellow.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced from 16 to 12
        child: Column(
          mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Reduced from 8 to 6
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Reduced from 10 to 8
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ), // Reduced from 20 to 18
                ),
                const Spacer(),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 11, // Reduced from 12 to 11
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6), // Reduced from 8 to 6
            Flexible(
              // Wrap with Flexible
              child: Text(
                count,
                style: const TextStyle(
                  fontSize: 22, // Reduced from 24 to 22
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
              ),
            ),
            Flexible(
              // Wrap with Flexible
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11, // Reduced from 12 to 11
                  color: darkBlack.withOpacity(0.7),
                ),
                maxLines: 1, // Ensure single line
                overflow: TextOverflow.ellipsis, // Handle overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentAnalytics() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business_rounded, color: primaryYellow, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Department Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Column(
                  children: departments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dept = entry.value;
                    return Transform.translate(
                      offset: Offset(
                        0,
                        30 * (1 - _cardAnimation.value) * (index + 1),
                      ),
                      child: Opacity(
                        opacity: _cardAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: _buildDepartmentCard(dept),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(Department dept) {
    return Container(
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dept.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dept.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(
                      dept.attendanceRate,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dept.attendanceRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getAttendanceColor(dept.attendanceRate),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDeptStat(
                    'Present',
                    dept.presentToday,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildDeptStat('Absent', dept.absentToday, Colors.red),
                ),
                Expanded(
                  child: _buildDeptStat('Late', dept.lateToday, Colors.orange),
                ),
                Expanded(
                  child: _buildDeptStat(
                    'Total',
                    dept.totalEmployees,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: dept.attendanceRate / 100,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(dept.color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 80) return Colors.orange;
    return Colors.red;
  }

  Widget _buildAttendanceChart() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_rounded, color: primaryYellow, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Attendance Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, lightYellow.withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryYellow.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: CustomPaint(
                          painter: PieChartPainter(
                            departments: departments,
                            animationValue: _chartAnimation.value,
                          ),
                          size: const Size(200, 200),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: departments.map((dept) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: dept.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dept.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: darkBlack,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, color: primaryYellow, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              return AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      30 * (1 - _cardAnimation.value) * (index + 1),
                    ),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _buildActivityCard(record),
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(AttendanceRecord record) {
    Color statusColor;
    IconData statusIcon;

    switch (record.status) {
      case 'Present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'Absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: primaryYellow.withOpacity(0.2),
              backgroundImage: NetworkImage(record.profilePic),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.employeeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    record.department,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        record.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.checkIn,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryYellow, darkYellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to detailed reports
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.analytics, color: Colors.white),
        label: const Text(
          'View Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<Department> departments;
  final double animationValue;

  PieChartPainter({required this.departments, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    final total = departments.fold(0, (sum, dept) => sum + dept.totalEmployees);

    double startAngle = -pi / 2;

    for (final dept in departments) {
      final sweepAngle =
          (dept.totalEmployees / total) * 2 * pi * animationValue;

      final paint = Paint()
        ..color = dept.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
