import 'package:ata_mobile/DioService/api_service.dart';
import 'package:ata_mobile/Screens/Dashboard/Attendance/LocationScreen.dart';
import 'package:ata_mobile/Utilities/SharedPrefManager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class AttendanceRecord {
  final int id;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final DateTime date;

  AttendanceRecord({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.date,
  });
}

class EmployeeAttendanceScreen extends StatefulWidget {
  final String employeeName;
  final int employeeId;

  const EmployeeAttendanceScreen({
    super.key,
    required this.employeeName,
    required this.employeeId,
  });

  @override
  State<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen>
    with TickerProviderStateMixin {
  // Reduced animations for better performance
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);
  static const Color cardWhite = Color(0xFFFAFAFA);

  bool isCheckedIn = false;
  bool isCheckedOut = false;
  bool _hasLoadedData = false;
  bool _isLoadingDialogShowing = false;
  bool _isInitialized = false; // Add this flag

  List<AttendanceRecord> monthlyRecords = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Use post frame callback to ensure widget is built before showing dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        _loadInitialData();
      }
    });
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  // Combine both data loading methods with proper sequencing
  Future<void> _loadInitialData() async {
    if (!mounted) return;

    // Load attendance data first
    await _loadAttendanceData();

    // Then load monthly data
    await _getMonthlyData();
  }

  void _showLoadingDialog(String message) {
    if (_isLoadingDialogShowing || !mounted) return;

    _isLoadingDialogShowing = true;

    // Use addPostFrameCallback to ensure we're not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isLoadingDialogShowing) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryYellow.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryYellow, darkYellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please wait...',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkBlack.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ).whenComplete(() {
          _isLoadingDialogShowing = false;
        });
      }
    });
  }

  void _hideLoadingDialog() {
    if (_isLoadingDialogShowing && mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
      _isLoadingDialogShowing = false;
    }
  }

  Future<void> _getMonthlyData() async {
    if (!mounted) return;

    try {
      final response = await ApiService().getMonthlyRecord(
        widget.employeeId,
        DateTime.now().month,
        DateTime.now().year,
      );

      if (!mounted) return;

      if (response["STS"] == "200") {
        List<dynamic> records = response["CONTENT"];
        List<AttendanceRecord> newRecords = records.map((record) {
          // Parse date array [year, month, day] to DateTime
          List<int> dateArray = List<int>.from(record["date"]);
          DateTime recordDate = DateTime(
            dateArray[0],
            dateArray[1],
            dateArray[2],
          );

          // Parse timestamp (milliseconds since epoch) to DateTime
          DateTime? checkInTime;
          DateTime? checkOutTime;

          if (record["checkIn"] != null) {
            checkInTime = DateTime.fromMillisecondsSinceEpoch(
              record["checkIn"],
            );
          }

          if (record["checkOut"] != null) {
            checkOutTime = DateTime.fromMillisecondsSinceEpoch(
              record["checkOut"],
            );
          }

          String status = "On Time";

          return AttendanceRecord(
            id: record["id"],
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            status: status,
            date: recordDate,
          );
        }).toList();

        // Sort records by date (newest first)
        newRecords.sort((a, b) => b.date.compareTo(a.date));

        if (mounted) {
          setState(() {
            monthlyRecords = newRecords;
          });
        }
      } else {
        print('Failed to load monthly data: ${response["MSG"]}');
        if (mounted) {
          _showErrorDialogDelayed(response["MSG"] ?? "Unknown error occurred");
        }
      }
    } catch (e) {
      print('Error fetching monthly data: $e');
      if (mounted) {
        _showErrorDialogDelayed(
          'Failed to load monthly attendance data. Please try again later.',
        );
      }
    }
  }

  Future<void> _loadAttendanceData() async {
    if (!mounted) return;

    _showLoadingDialog('Loading Attendance Data');

    try {
      final response = await ApiService().getTodaysAttendance(
        widget.employeeId,
      );

      _hideLoadingDialog();

      if (!mounted) return;

      if (response["STS"] == "200") {
        String? storedCheckIn = response["CONTENT"]["checkIn"]?.toString();
        String? storedCheckOut = response["CONTENT"]["checkOut"]?.toString();

        print('Stored Check In: $storedCheckIn');
        print('Stored Check Out: $storedCheckOut');

        if (mounted) {
          setState(() {
            isCheckedIn =
                storedCheckIn != null &&
                storedCheckIn.isNotEmpty &&
                storedCheckIn != "null";

            isCheckedOut =
                storedCheckOut != null &&
                storedCheckOut.isNotEmpty &&
                storedCheckOut != "null";
          });
        }

        print(
          'Final state - isCheckedIn: $isCheckedIn, isCheckedOut: $isCheckedOut',
        );
      } else {
        print('Failed to load attendance data: ${response["MSG"]}');
        String errorMessage = response["MSG"] ?? "Unknown error occurred";
        if (response["STS"] == "500") {
          errorMessage =
              response["MSG"] ??
              "Server error occurred. Please try again later.";
        }
        _showErrorDialogDelayed(errorMessage);
      }
    } catch (e) {
      _hideLoadingDialog();

      if (!mounted) return;

      print('Error loading attendance data: $e');
      _showErrorDialogDelayed(
        'Network error occurred. Please check your connection and try again.',
      );
    }
  }

  // Delayed error dialog to avoid build phase conflicts
  void _showErrorDialogDelayed(String message) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showErrorDialog(message);
      }
    });
  }

  Future<void> _handleCheckIn() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationBasedAttendanceScreen(
          employeeName: widget.employeeName,
          employeeId: widget.employeeId,
        ),
      ),
    );

    if (result != null && result['isCheckedIn'] == true) {
      await _loadAttendanceData();
      if (mounted) {
        _showSuccessDialogDelayed('Checked In Successfully!');
      }
    }
  }

  Future<void> _handleCheckOut() async {
    _showLoadingDialog('Processing Check Out');

    try {
      final response = await ApiService().checkOut(widget.employeeId);

      _hideLoadingDialog();

      if (!mounted) return;

      if (response["STS"] == "200") {
        setState(() {
          isCheckedOut = true;
        });
        _showSuccessDialogDelayed('Checked Out Successfully!');
      } else {
        String errorMessage = response["MSG"] ?? "Unknown error occurred";
        if (response["STS"] == "500") {
          errorMessage = "Server error occurred. Please try again later.";
        }
        _showErrorDialogDelayed('Check Out Failed: $errorMessage');
      }
    } catch (e) {
      _hideLoadingDialog();

      if (!mounted) return;

      print('Error during check out: $e');
      _showErrorDialogDelayed(
        'Network error occurred during check out. Please try again.',
      );
    }
  }

  void _showSuccessDialogDelayed(String message) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showSuccessDialog(message);
      }
    });
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryYellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: primaryYellow, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Success!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: darkBlack.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                  color: darkBlack.withOpacity(0.5),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: primaryYellow)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Error',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: darkBlack.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Retry loading data
                _loadInitialData();
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: primaryYellow),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String _getAttendanceStatus() {
    if (!isCheckedIn) {
      return 'Not Checked In';
    } else if (isCheckedIn && !isCheckedOut) {
      return 'Checked In';
    } else {
      return 'Work Completed';
    }
  }

  Color _getStatusColor() {
    if (!isCheckedIn) {
      return Colors.red;
    } else if (isCheckedIn && !isCheckedOut) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  Widget _getActionButton() {
    if (!isCheckedIn) {
      // Show Check In button
      return _buildActionButton(
        text: 'CHECK IN',
        icon: Icons.login,
        onPressed: _handleCheckIn,
        colors: [primaryYellow, darkYellow],
        textColor: darkBlack,
      );
    } else if (isCheckedIn && !isCheckedOut) {
      // Show Check Out button
      return _buildActionButton(
        text: 'CHECK OUT',
        icon: Icons.logout,
        onPressed: _handleCheckOut,
        colors: [Colors.red.shade400, Colors.red.shade600],
        textColor: Colors.white,
      );
    } else {
      // Both check-in and check-out completed - show disabled button
      return Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.grey.shade600, size: 24),
              const SizedBox(width: 10),
              Text(
                'WORK COMPLETED',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> colors,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlack,
      body: CustomScrollView(
        slivers: [
          _buildAnimatedHeader(),
          _buildCurrentStatusCard(),
          _buildQuickStats(),
          _buildTodayAttendance(),
          _buildMonthlyReport(),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: darkBlack,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: primaryYellow),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Attendance',
          style: TextStyle(
            color: primaryYellow,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: primaryYellow.withOpacity(0.5),
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [darkBlack, lightBlack.withOpacity(0.8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardWhite, cardWhite.withOpacity(0.9)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: primaryYellow.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: primaryYellow.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: darkYellow,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: TextStyle(
                            fontSize: 16,
                            color: darkBlack.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _getAttendanceStatus(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _getActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    // Calculate stats from monthly records
    int presentDays = 0;
    int absentDays = 0;
    int lateDays = 0;

    // Get current month's total days
    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int currentDay = now.day;

    // Count present and late days from records
    for (AttendanceRecord record in monthlyRecords) {
      if (record.checkInTime != null) {
        presentDays++;
        if (record.status == 'Late') {
          lateDays++;
        }
      }
    }

    // Calculate absent days (total working days - present days)
    // Assuming weekends are not working days
    int workingDaysUpToToday = 0;
    for (int day = 1; day <= currentDay; day++) {
      DateTime date = DateTime(now.year, now.month, day);
      // Skip weekends (Saturday = 6, Sunday = 7)
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        workingDaysUpToToday++;
      }
    }

    absentDays = workingDaysUpToToday - presentDays;
    if (absentDays < 0) absentDays = 0; // Ensure non-negative

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Present Days',
                presentDays.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Absent Days',
                absentDays.toString(),
                Icons.cancel,
                Colors.red,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Late Days',
                lateDays.toString(),
                Icons.access_time,
                Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: darkBlack.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAttendance() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lightBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryYellow.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: primaryYellow, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Today\'s Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isCheckedIn)
              _buildSummaryRow('Check In Status', 'Completed', Icons.login),
            if (isCheckedOut)
              _buildSummaryRow('Check Out Status', 'Completed', Icons.logout),
            if (!isCheckedIn)
              _buildSummaryRow('Status', 'Not Checked In', Icons.pending),
            if (isCheckedIn && !isCheckedOut)
              _buildSummaryRow('Status', 'Currently Working', Icons.work),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryYellow, size: 16),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryYellow.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryYellow, darkYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: darkBlack, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Monthly Report - ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: monthlyRecords.isEmpty
                  ? const Center(
                      child: Text(
                        'No attendance records found',
                        style: TextStyle(color: darkBlack, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: math.min(monthlyRecords.length, 8),
                      itemBuilder: (context, index) {
                        final record = monthlyRecords[index];
                        return _buildAttendanceRecord(record);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecord(AttendanceRecord record) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: record.status == 'Late'
              ? Colors.orange.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: record.status == 'Late'
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              record.status == 'Late' ? Icons.schedule : Icons.check_circle,
              color: record.status == 'Late' ? Colors.orange : Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(record.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkBlack,
                  ),
                ),
                Text(
                  '${record.checkInTime != null ? DateFormat('hh:mm a').format(record.checkInTime!) : 'Not checked in'} - ${record.checkOutTime != null ? DateFormat('hh:mm a').format(record.checkOutTime!) : 'Not checked out'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: darkBlack.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: record.status == 'Late' ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              record.status,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
