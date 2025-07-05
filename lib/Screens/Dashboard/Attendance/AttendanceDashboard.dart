import 'package:ata_mobile/Screens/Dashboard/Attendance/AttendanceReportScreen.dart';
import 'package:flutter/material.dart';
import 'package:ata_mobile/DioService/api_service.dart';
import 'dart:math';

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

  // API Response Data
  Map<String, dynamic>? todayAttendanceData;
  Map<String, dynamic>? weekAttendanceData;
  Map<String, dynamic>? monthAttendanceData;
  Map<String, dynamic>? yearAttendanceData;
  bool isLoading = true;
  String errorMessage = '';

  // Default data for other periods
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

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTodayAttendanceData();
    _loadWeekAttendanceData();
    _loadMonthAttendanceData();
    _loadYearAttendanceData();
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

  Future<void> _loadTodayAttendanceData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService().getTodayOverallAttendance();

      if (response["STS"] == "200") {
        setState(() {
          todayAttendanceData = response["CONTENT"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response["MSG"] ?? "Failed to load attendance data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading attendance data: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _loadWeekAttendanceData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService().getWeekOverallAttendance();

      if (response["STS"] == "200") {
        setState(() {
          weekAttendanceData = response["CONTENT"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response["MSG"] ?? "Failed to load attendance data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading attendance data: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _loadMonthAttendanceData() async {
    final month = DateTime.now().month;
    final year = DateTime.now().year;

    if (month < 1 || month > 12 || year < 2000) {
      setState(() {
        errorMessage = "Invalid month or year";
        isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService().getMonthOverallAttendance(
        month,
        year,
      );

      if (response["STS"] == "200") {
        setState(() {
          monthAttendanceData = response["CONTENT"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response["MSG"] ?? "Failed to load attendance data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading attendance data: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _loadYearAttendanceData() async {
    final year = DateTime.now().year;
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService().getYearOverallAttendance(year);

      if (response["STS"] == "200") {
        setState(() {
          yearAttendanceData = response["CONTENT"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response["MSG"] ?? "Failed to load attendance data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading attendance data: $e";
        isLoading = false;
      });
    }
  }

  // Convert API data to Department objects
  List<Department> _getApiDepartments(Map<String, dynamic> data) {
    if (data == null) return [];

    List<dynamic> departmentStats = data["departmentWiseStats"];
    List<Color> colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFFF5722),
      const Color(0xFFFF9800),
      const Color(0xFF607D8B),
    ];

    return departmentStats.asMap().entries.map((entry) {
      final index = entry.key;
      final dept = entry.value;

      final totalPresent = dept["totalPresent"] ?? 0;
      final late = dept["late"] ?? 0;
      final onTime = dept["onTime"] ?? 0;
      final totalEmployees =
          totalPresent; // Assuming total employees = present today
      final attendanceRate = totalEmployees > 0
          ? (totalPresent / totalEmployees) * 100
          : 0.0;

      return Department(
        name: dept["departmentName"] ?? "Unknown",
        totalEmployees: totalEmployees,
        presentToday: totalPresent,
        absentToday: 0, // Not provided in API
        lateToday: late,
        attendanceRate: attendanceRate,
        color: colors[index % colors.length],
      );
    }).toList();
  }

  // Get overall stats from API
  Map<String, int> _getOverallStats(Map<String, dynamic>? data) {
    if (data == null) {
      return {'totalPresent': 0, 'totalAbsent': 0, 'totalLate': 0};
    }

    final overallStats = data["overallStats"];
    return {
      'totalPresent': overallStats["totalPresent"] ?? 0,
      'totalAbsent': 0, // Not provided in API
      'totalLate': overallStats["totalLate"] ?? 0,
    };
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
      body: isLoading
          ? _buildLoadingScreen()
          : errorMessage.isNotEmpty
          ? _buildErrorScreen()
          : CustomScrollView(
              slivers: [
                _buildAnimatedHeader(),
                _buildPeriodSelector(),
                _buildOverviewCards(),
                _buildDepartmentAnalytics(),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryYellow, darkYellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading Attendance Data...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.error_outline, size: 60, color: Colors.red),
          ),
          const SizedBox(height: 20),
          const Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadTodayAttendanceData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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
                    if (period == 'Today') {
                      _loadTodayAttendanceData();
                    }
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
          final stats = selectedPeriod == 'Today' && todayAttendanceData != null
              ? _getOverallStats(todayAttendanceData!)
              : selectedPeriod == 'This Week' && weekAttendanceData != null
              ? _getOverallStats(weekAttendanceData!)
              : selectedPeriod == 'This Month' && monthAttendanceData != null
              ? _getOverallStats(monthAttendanceData!)
              : selectedPeriod == 'This Year' && yearAttendanceData != null
              ? _getOverallStats(yearAttendanceData!)
              // Default to overall stats if no specific data is available
              : _getOverallStats(null);

          final totalEmployees = stats['totalPresent']! + stats['totalAbsent']!;
          final presentPercentage = totalEmployees > 0
              ? (stats['totalPresent']! / totalEmployees * 100).toStringAsFixed(
                  1,
                )
              : '0.0';
          final absentPercentage = totalEmployees > 0
              ? (stats['totalAbsent']! / totalEmployees * 100).toStringAsFixed(
                  1,
                )
              : '0.0';
          final latePercentage = totalEmployees > 0
              ? (stats['totalLate']! / totalEmployees * 100).toStringAsFixed(1)
              : '0.0';
          return Container(
            height: 130,
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
                        stats['totalPresent'].toString(),
                        Icons.check_circle_rounded,
                        const Color(0xFF4CAF50),
                        '$presentPercentage%',
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
                        stats['totalAbsent'].toString(),
                        Icons.cancel_rounded,
                        Colors.red,
                        '$absentPercentage%',
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
                        stats['totalLate'].toString(),
                        Icons.access_time_rounded,
                        Colors.orange,
                        '$latePercentage%',
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
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                count,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
              ),
            ),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: darkBlack.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                final depts = <Department>[];
                if (selectedPeriod == 'Today' && todayAttendanceData != null) {
                  depts.addAll(_getApiDepartments(todayAttendanceData!));
                } else if (selectedPeriod == 'This Week' &&
                    weekAttendanceData != null) {
                  depts.addAll(_getApiDepartments(weekAttendanceData!));
                } else if (selectedPeriod == 'This Month' &&
                    monthAttendanceData != null) {
                  depts.addAll(_getApiDepartments(monthAttendanceData!));
                } else if (selectedPeriod == 'This Year' &&
                    yearAttendanceData != null) {
                  depts.addAll(_getApiDepartments(yearAttendanceData!));
                } else {
                  depts.addAll(departments);
                }
                return Column(
                  children: depts.asMap().entries.map((entry) {
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AttendanceReportScreen()),
          );
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
