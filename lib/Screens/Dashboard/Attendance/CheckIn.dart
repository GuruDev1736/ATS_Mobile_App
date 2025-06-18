import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class AttendanceRecord {
  final int id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final Duration? workingHours;
  final String status;
  final DateTime date;

  AttendanceRecord({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    this.workingHours,
    required this.status,
    required this.date,
  });
}

class EmployeeAttendanceScreen extends StatefulWidget {
  final String employeeName;
  final String employeeId;

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
  late AnimationController _clockController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);
  static const Color cardWhite = Color(0xFFFAFAFA);

  bool isCheckedIn = false;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  Duration currentWorkingTime = Duration.zero;

  // Sample data - replace with actual API calls
  List<AttendanceRecord> monthlyRecords = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateSampleData();
    _startWorkingTimeTimer();
  }

  void _initializeAnimations() {
    _clockController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _slideController.forward();
  }

  void _generateSampleData() {
    monthlyRecords = List.generate(20, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      final checkIn = DateTime(
        date.year,
        date.month,
        date.day,
        9,
        0 + math.Random().nextInt(60),
      );
      final checkOut = DateTime(
        date.year,
        date.month,
        date.day,
        17,
        0 + math.Random().nextInt(120),
      );

      return AttendanceRecord(
        id: index,
        checkInTime: checkIn,
        checkOutTime: checkOut,
        workingHours: checkOut.difference(checkIn),
        status: index % 10 == 0 ? 'Late' : 'On Time',
        date: date,
      );
    });
  }

  void _startWorkingTimeTimer() {
    if (isCheckedIn && checkInTime != null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && isCheckedIn) {
          setState(() {
            currentWorkingTime = DateTime.now().difference(checkInTime!);
          });
          _startWorkingTimeTimer();
        }
      });
    }
  }

  void _handleCheckIn() {
    setState(() {
      isCheckedIn = true;
      checkInTime = DateTime.now();
      checkOutTime = null;
      currentWorkingTime = Duration.zero;
    });
    _startWorkingTimeTimer();
    _showSuccessDialog('Checked In Successfully!');
  }

  void _handleCheckOut() {
    setState(() {
      isCheckedIn = false;
      checkOutTime = DateTime.now();
    });
    _showSuccessDialog('Checked Out Successfully!');
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
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
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now()),
                style: TextStyle(color: darkBlack.withOpacity(0.6)),
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

  @override
  void dispose() {
    _clockController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
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
                  AnimatedBuilder(
                    animation: _clockController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _clockController.value * 2 * math.pi,
                        child: Container(
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
                      );
                    },
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
                          isCheckedIn ? 'Checked In' : 'Not Checked In',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isCheckedIn ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              if (isCheckedIn) ...[
                _buildTimeDisplay(),
                const SizedBox(height: 25),
              ],
              _buildCheckInOutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightYellow.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Working Time',
            style: TextStyle(fontSize: 14, color: darkBlack.withOpacity(0.7)),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDuration(currentWorkingTime),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: darkBlack,
              letterSpacing: 2,
            ),
          ),
          if (checkInTime != null) ...[
            const SizedBox(height: 10),
            Text(
              'Started at ${DateFormat('hh:mm a').format(checkInTime!)}',
              style: TextStyle(fontSize: 14, color: darkBlack.withOpacity(0.6)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckInOutButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isCheckedIn ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCheckedIn
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [primaryYellow, darkYellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: (isCheckedIn ? Colors.red : primaryYellow).withOpacity(
                    0.4,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isCheckedIn ? _handleCheckOut : _handleCheckIn,
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
                  Icon(
                    isCheckedIn ? Icons.logout : Icons.login,
                    color: isCheckedIn ? Colors.white : darkBlack,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCheckedIn ? Colors.white : darkBlack,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Present Days',
                '22',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Absent Days',
                '3',
                Icons.cancel,
                Colors.red,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Late Days',
                '2',
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
            if (checkInTime != null)
              _buildSummaryRow(
                'Check In',
                DateFormat('hh:mm a').format(checkInTime!),
                Icons.login,
              ),
            if (checkOutTime != null)
              _buildSummaryRow(
                'Check Out',
                DateFormat('hh:mm a').format(checkOutTime!),
                Icons.logout,
              ),
            if (isCheckedIn)
              _buildSummaryRow(
                'Current Time',
                _formatDuration(currentWorkingTime),
                Icons.timer,
              ),
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
                  Text(
                    'Monthly Report - ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBlack,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 300,
              child: ListView.builder(
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
                  '${DateFormat('hh:mm a').format(record.checkInTime)} - ${record.checkOutTime != null ? DateFormat('hh:mm a').format(record.checkOutTime!) : 'Not checked out'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: darkBlack.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.workingHours != null
                    ? _formatDuration(record.workingHours!)
                    : '--',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
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
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
