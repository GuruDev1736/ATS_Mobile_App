import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeStatusScreen extends StatefulWidget {
  const EmployeeStatusScreen({super.key});

  @override
  State<EmployeeStatusScreen> createState() => _EmployeeStatusScreenState();
}

class _EmployeeStatusScreenState extends State<EmployeeStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _tabController;
  late TabController _statusTabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);

  String selectedStatus = 'All';
  final List<String> statusFilters = ['All', 'Present', 'Late', 'Absent'];

  // Mock employee data
  final List<EmployeeStatus> employees = [
    EmployeeStatus(
      id: '001',
      name: 'John Doe',
      department: 'Engineering',
      position: 'Senior Developer',
      checkInTime: '09:00 AM',
      status: 'Present',
      profilePic: '',
      shift: '09:00 AM - 06:00 PM',
      location: 'Office Floor 2',
    ),
    EmployeeStatus(
      id: '002',
      name: 'Sarah Wilson',
      department: 'Design',
      position: 'UI/UX Designer',
      checkInTime: '09:15 AM',
      status: 'Late',
      profilePic: '',
      shift: '09:00 AM - 06:00 PM',
      location: 'Office Floor 3',
    ),
    EmployeeStatus(
      id: '003',
      name: 'Mike Johnson',
      department: 'Marketing',
      position: 'Marketing Manager',
      checkInTime: '',
      status: 'Absent',
      profilePic: '',
      shift: '09:00 AM - 06:00 PM',
      location: 'Office Floor 1',
    ),
    EmployeeStatus(
      id: '004',
      name: 'Emily Davis',
      department: 'HR',
      position: 'HR Specialist',
      checkInTime: '08:45 AM',
      status: 'Present',
      profilePic: '',
      shift: '09:00 AM - 06:00 PM',
      location: 'Office Floor 4',
    ),
    EmployeeStatus(
      id: '005',
      name: 'Alex Brown',
      department: 'Sales',
      position: 'Sales Executive',
      checkInTime: '09:30 AM',
      status: 'Late',
      profilePic: '',
      shift: '09:00 AM - 06:00 PM',
      location: 'Office Floor 1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _tabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _statusTabController = TabController(length: 4, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    _statusTabController.dispose();
    super.dispose();
  }

  List<EmployeeStatus> get filteredEmployees {
    if (selectedStatus == 'All') return employees;
    return employees.where((emp) => emp.status == selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlack,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildAnimatedAppBar(),
            _buildSummaryCards(),
            _buildStatusFilter(),
            _buildEmployeeList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: primaryYellow,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryYellow, darkYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Animated background elements
            Positioned(
              top: 30,
              right: 20,
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _fadeController.value * 0.5,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        size: 40,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Employee Status',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final presentCount = employees.where((e) => e.status == 'Present').length;
    final lateCount = employees.where((e) => e.status == 'Late').length;
    final absentCount = employees.where((e) => e.status == 'Absent').length;

    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: 120,
          margin: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Present',
                  presentCount,
                  Icons.check_circle_rounded,
                  Colors.green,
                  0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Late',
                  lateCount,
                  Icons.access_time_rounded,
                  Colors.orange,
                  1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Absent',
                  absentCount,
                  Icons.cancel_rounded,
                  Colors.red,
                  2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    IconData icon,
    Color color,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value) * (index + 1)),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, lightYellow.withOpacity(0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkBlack,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: darkBlack.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusFilter() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: lightBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryYellow.withOpacity(0.3)),
        ),
        child: Row(
          children: statusFilters.map((status) {
            final isSelected = selectedStatus == status;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedStatus = status;
                  });
                  _tabController.forward().then(
                    (_) => _tabController.reverse(),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [primaryYellow, darkYellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black87 : Colors.white,
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

  Widget _buildEmployeeList() {
    final filtered = filteredEmployees;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final employee = filtered[index];
        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                30 * (1 - _slideController.value) * (index + 1),
              ),
              child: Opacity(
                opacity: _slideController.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: _buildEmployeeCard(employee),
                ),
              ),
            );
          },
        );
      }, childCount: filtered.length),
    );
  }

  Widget _buildEmployeeCard(EmployeeStatus employee) {
    final statusColor = _getStatusColor(employee.status);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightBlack, lightBlack.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEmployeeDetails(employee),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Profile section
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.3),
                            statusColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.transparent,
                        backgroundImage: employee.profilePic.isNotEmpty
                            ? NetworkImage(employee.profilePic)
                            : null,
                        child: employee.profilePic.isEmpty
                            ? Text(
                                employee.name
                                    .split(' ')
                                    .map((n) => n[0])
                                    .join(''),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: lightBlack, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Employee info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              employee.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              employee.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.position,
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            employee.department,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (employee.checkInTime.isNotEmpty) ...[
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              employee.checkInTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Action button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: primaryYellow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Late':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEmployeeDetails(EmployeeStatus employee) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEmployeeDetailsSheet(employee),
    );
  }

  Widget _buildEmployeeDetailsSheet(EmployeeStatus employee) {
    final statusColor = _getStatusColor(employee.status);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withOpacity(0.3),
                              statusColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: employee.profilePic.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  employee.profilePic,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  employee.name
                                      .split(' ')
                                      .map((n) => n[0])
                                      .join(''),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.position,
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryYellow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                employee.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Details
                  _buildDetailRow(
                    icon: Icons.badge_rounded,
                    title: 'Employee ID',
                    value: employee.id,
                  ),
                  _buildDetailRow(
                    icon: Icons.business_rounded,
                    title: 'Department',
                    value: employee.department,
                  ),
                  _buildDetailRow(
                    icon: Icons.schedule_rounded,
                    title: 'Shift Timing',
                    value: employee.shift,
                  ),
                  if (employee.checkInTime.isNotEmpty)
                    _buildDetailRow(
                      icon: Icons.login_rounded,
                      title: 'Check-in Time',
                      value: employee.checkInTime,
                    ),
                  _buildDetailRow(
                    icon: Icons.location_on_rounded,
                    title: 'Location',
                    value: employee.location,
                  ),

                  const Spacer(),

                  // Action buttons
                  if (employee.status != 'Absent')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Add message functionality
                            },
                            icon: const Icon(Icons.message_rounded),
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryYellow,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Add call functionality
                            },
                            icon: const Icon(Icons.phone_rounded),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: primaryYellow),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

class EmployeeStatus {
  final String id;
  final String name;
  final String department;
  final String position;
  final String checkInTime;
  final String status;
  final String profilePic;
  final String shift;
  final String location;

  EmployeeStatus({
    required this.id,
    required this.name,
    required this.department,
    required this.position,
    required this.checkInTime,
    required this.status,
    required this.profilePic,
    required this.shift,
    required this.location,
  });
}
