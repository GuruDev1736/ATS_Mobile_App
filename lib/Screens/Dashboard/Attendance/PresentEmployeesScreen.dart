import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PresentEmployeesScreen extends StatefulWidget {
  final String period;
  final int totalCount;
  final String type; // 'Present', 'Late', 'Absent'
  final List<Employee> employees; // Add this parameter

  const PresentEmployeesScreen({
    super.key,
    required this.period,
    required this.totalCount,
    required this.type,
    required this.employees, // Add this parameter
  });

  @override
  State<PresentEmployeesScreen> createState() => _PresentEmployeesScreenState();
}

class _PresentEmployeesScreenState extends State<PresentEmployeesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);

  String searchQuery = '';
  String selectedDepartment = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Get theme colors based on type
  Map<String, dynamic> get typeConfig {
    switch (widget.type) {
      case 'Present':
        return {
          'primaryColor': Colors.green,
          'secondaryColor': Colors.green.shade400,
          'tertiaryColor': Colors.green.shade600,
          'icon': Icons.check_circle_rounded,
          'title': 'Present Employees',
          'subtitle': 'Active & Working',
          'gradientColors': [
            Colors.green.shade400,
            Colors.green.shade500,
            Colors.green.shade600,
          ],
        };
      case 'Late':
        return {
          'primaryColor': Colors.orange,
          'secondaryColor': Colors.orange.shade400,
          'tertiaryColor': Colors.orange.shade600,
          'icon': Icons.access_time_rounded,
          'title': 'Late Employees',
          'subtitle': 'Arrived Late Today',
          'gradientColors': [
            Colors.orange.shade400,
            Colors.orange.shade500,
            Colors.orange.shade600,
          ],
        };
      case 'Absent':
        return {
          'primaryColor': Colors.red,
          'secondaryColor': Colors.red.shade400,
          'tertiaryColor': Colors.red.shade600,
          'icon': Icons.cancel_rounded,
          'title': 'Absent Employees',
          'subtitle': 'Not Present Today',
          'gradientColors': [
            Colors.red.shade400,
            Colors.red.shade500,
            Colors.red.shade600,
          ],
        };
      default:
        return {
          'primaryColor': Colors.grey,
          'secondaryColor': Colors.grey.shade400,
          'tertiaryColor': Colors.grey.shade600,
          'icon': Icons.people_rounded,
          'title': 'Employees',
          'subtitle': 'All Employees',
          'gradientColors': [
            Colors.grey.shade400,
            Colors.grey.shade500,
            Colors.grey.shade600,
          ],
        };
    }
  }

  // Get departments from the passed employees list
  List<String> get departments {
    final depts = widget.employees.map((e) => e.department).toSet().toList();
    depts.insert(0, 'All');
    return depts;
  }

  // Filter employees based on search and department
  List<Employee> get filteredEmployees {
    return widget.employees.where((employee) {
      final matchesSearch =
          employee.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          employee.position.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesDepartment =
          selectedDepartment == 'All' ||
          employee.department == selectedDepartment;
      return matchesSearch && matchesDepartment;
    }).toList();
  }

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
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _showErrorDialog('Phone number not available');
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorDialog('Could not launch phone dialer');
      }
    } catch (e) {
      _showErrorDialog('Error launching phone dialer: $e');
    }
  }

  // Add SMS functionality
  Future<void> _sendSMS(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _showErrorDialog('Phone number not available');
      return;
    }

    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        _showErrorDialog('Could not launch SMS');
      }
    } catch (e) {
      _showErrorDialog('Error launching SMS: $e');
    }
  }

  // Add WhatsApp functionality
  Future<void> _sendWhatsApp(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _showErrorDialog('Phone number not available');
      return;
    }

    // Remove any non-numeric characters and ensure proper format
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+$cleanNumber';
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('WhatsApp not installed');
      }
    } catch (e) {
      _showErrorDialog('Error launching WhatsApp: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlack,
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: primaryYellow)),
          ),
        ],
      ),
    );
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
            _buildStatsHeader(),
            _buildSearchAndFilter(),
            _buildEmployeeList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    final config = typeConfig;
    return SliverAppBar(
      expandedHeight: 200,
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
                  colors: [primaryYellow, darkYellow, config['secondaryColor']],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.7, 1.0],
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
            Positioned(
              top: 70,
              left: 30,
              child: AnimatedBuilder(
                animation: _slideController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.5 + (_slideController.value * 0.5),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
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
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        config['icon'],
                        size: 40,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      config['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                            color: Colors.white30,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${widget.period} • ${filteredEmployees.length} ${config['subtitle']}',
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

  Widget _buildStatsHeader() {
    final config = typeConfig;
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: config['gradientColors'],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: config['primaryColor'].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(config['icon'], size: 40, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.totalCount}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Employees ${widget.type} Today',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTypeSpecificStats(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificStats() {
    switch (widget.type) {
      case 'Present':
        return Row(
          children: [
            _buildQuickStat(
              'In Office',
              _getInOfficeCount(),
              Icons.business_rounded,
            ),
            const SizedBox(width: 16),
            _buildQuickStat('Remote', _getRemoteCount(), Icons.home_rounded),
          ],
        );
      case 'Late':
        return Row(
          children: [
            _buildQuickStat(
              '< 30 min',
              _getLateCount('< 30 min'),
              Icons.schedule_rounded,
            ),
            const SizedBox(width: 16),
            _buildQuickStat(
              '> 30 min',
              _getLateCount('> 30 min'),
              Icons.warning_rounded,
            ),
          ],
        );
      case 'Absent':
        return Row(
          children: [
            _buildQuickStat(
              'Sick Leave',
              _getAbsentCount('Sick'),
              Icons.local_hospital_rounded,
            ),
            const SizedBox(width: 16),
            _buildQuickStat(
              'Personal',
              _getAbsentCount('Personal'),
              Icons.person_rounded,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQuickStat(String label, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: lightBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryYellow.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search employees...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search_rounded, color: primaryYellow),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.white,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Department Filter
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  final dept = departments[index];
                  final isSelected = selectedDepartment == dept;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDepartment = dept;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [primaryYellow, darkYellow],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : lightBlack,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : primaryYellow.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          dept,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
          animation: _staggerController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = (_staggerController.value - delay).clamp(
              0.0,
              1.0,
            );

            return Transform.translate(
              offset: Offset(0, 50 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
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

  Widget _buildEmployeeCard(Employee employee) {
    final config = typeConfig;
    final statusColor = config['primaryColor'];

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
                // Profile section with status indicator
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
                    // Status indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: widget.type == 'Present' && employee.onBreak
                              ? Colors.orange
                              : statusColor,
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
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.type,
                              style: TextStyle(
                                fontSize: 10,
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
                            size: 12,
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
                          if (employee.checkInTime.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
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
                      const SizedBox(height: 4),
                      _buildTypeSpecificInfo(employee, statusColor),
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

  Widget _buildTypeSpecificInfo(Employee employee, Color statusColor) {
    switch (widget.type) {
      case 'Present':
        return Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 12,
              color: statusColor.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              'Working: ${employee.workingHours}',
              style: TextStyle(
                fontSize: 12,
                color: statusColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (employee.onBreak) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'On Break',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        );
      case 'Late':
        return Row(
          children: [
            Icon(
              Icons.warning_rounded,
              size: 12,
              color: statusColor.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              'Reason: ${employee.reason}',
              style: TextStyle(
                fontSize: 12,
                color: statusColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case 'Absent':
        return Row(
          children: [
            Icon(
              Icons.info_rounded,
              size: 12,
              color: statusColor.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              'Reason: ${employee.reason}',
              style: TextStyle(
                fontSize: 12,
                color: statusColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showEmployeeDetails(Employee employee) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEmployeeDetailsSheet(employee),
    );
  }

  Widget _buildEmployeeDetailsSheet(Employee employee) {
    final config = typeConfig;
    final statusColor = config['primaryColor'];

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with profile
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.type,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
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
                  if (employee.checkInTime.isNotEmpty)
                    _buildDetailRow(
                      icon: Icons.login_rounded,
                      title: 'Check-in Time',
                      value: employee.checkInTime,
                    ),
                  if (widget.type == 'Present')
                    _buildDetailRow(
                      icon: Icons.schedule_rounded,
                      title: 'Working Hours',
                      value: employee.workingHours,
                    ),
                  if (employee.location.isNotEmpty)
                    _buildDetailRow(
                      icon: Icons.location_on_rounded,
                      title: 'Location',
                      value: employee.location,
                    ),
                  if (employee.reason.isNotEmpty)
                    _buildDetailRow(
                      icon: Icons.info_rounded,
                      title: 'Reason',
                      value: employee.reason,
                    ),

                  const SizedBox(height: 30),

                  // Action buttons
                  if (widget.type != 'Absent')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _sendSMS(employee.phoneNumber);
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
                              _sendWhatsApp(employee.phoneNumber);
                            },
                            icon: const Icon(Icons.chat_bubble_outlined),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromARGB(
                                255,
                                17,
                                204,
                                23,
                              ),
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
                              _makePhoneCall(employee.phoneNumber);
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
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Add email functionality for absent employees
                        },
                        icon: const Icon(Icons.email_rounded),
                        label: const Text('Send Email'),
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

  // Helper methods for stats using the passed employees data
  int _getInOfficeCount() {
    return widget.employees.where((e) => e.status == 'In Office').length;
  }

  int _getRemoteCount() {
    return widget.employees.where((e) => e.status == 'Remote').length;
  }

  int _getLateCount(String category) {
    // You can implement actual logic based on your Employee model
    // For now, returning a simple count
    return category == '< 30 min'
        ? widget.employees.where((e) => e.reason.isNotEmpty).length ~/ 2
        : widget.employees.where((e) => e.reason.isNotEmpty).length ~/ 2;
  }

  int _getAbsentCount(String category) {
    return widget.employees
        .where((e) => e.reason.toLowerCase().contains(category.toLowerCase()))
        .length;
  }
}

// Employee model class
class Employee {
  final String id;
  final String name;
  final String department;
  final String position;
  final String checkInTime;
  final String location;
  final String profilePic;
  final String workingHours;
  final String status;
  final String type;
  final String reason;
  final bool onBreak;
  final String phoneNumber;
  final String email;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.position,
    required this.checkInTime,
    required this.location,
    required this.profilePic,
    required this.workingHours,
    required this.status,
    required this.type,
    required this.reason,
    required this.onBreak,
    required this.phoneNumber,
    required this.email,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      checkInTime: json['checkInTime'] ?? '',
      location: json['location'] ?? '',
      profilePic: json['profilePic'] ?? '',
      workingHours: json['workingHours'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      reason: json['reason'] ?? '',
      onBreak: json['onBreak'] ?? false,
      phoneNumber: json['phoneNo'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'position': position,
      'checkInTime': checkInTime,
      'location': location,
      'profilePic': profilePic,
      'workingHours': workingHours,
      'status': status,
      'type': type,
      'reason': reason,
      'onBreak': onBreak,
      'phoneNo': phoneNumber,
      'email': email,
    };
  }
}
