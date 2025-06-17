import 'package:ata_mobile/DioService/api_service.dart';
import 'package:ata_mobile/Screens/Dashboard/Employee/AddEmployee.dart';
import 'package:ata_mobile/Screens/Dashboard/Employee/UpdateEmployee.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class Department {
  final int id;
  final String name;
  final String description;

  Department({required this.id, required this.name, required this.description});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['departmentName'] ?? '',
      description: json['departmentDescription'] ?? '',
    );
  }
}

class Employee {
  final int id;
  final String fullName;
  final String email;
  final String password;
  final String phoneNo;
  final String address;
  final String profilePic;
  final DateTime joiningDate;
  final double salary;
  final String designation;
  final String shiftStartTime;
  final String shiftEndTime;
  final int departmentId;
  final String departmentName;

  Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNo,
    required this.address,
    required this.profilePic,
    required this.joiningDate,
    required this.salary,
    required this.designation,
    required this.shiftStartTime,
    required this.shiftEndTime,
    required this.departmentId,
    required this.departmentName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      address: json['address'] ?? '',
      profilePic: json['profile_pic'] ?? '',
      joiningDate: DateTime.parse(json['joiningDate']),
      salary: json['salary']?.toDouble() ?? 0.0,
      designation: json['designation'] ?? '',
      shiftStartTime: json['shiftStartTime'] ?? '',
      shiftEndTime: json['shiftEndTime'] ?? '',
      departmentId: json['department']['id'] ?? 0,
      departmentName: json['department']['departmentName'] ?? '',
    );
  }
}

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;
  final apiService = ApiService(); // Assuming ApiService is defined elsewhere

  final TextEditingController _searchController = TextEditingController();
  List<Employee> _filteredEmployees = [];
  List<Department> departments = [];

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);
  static const Color cardWhite = Color(0xFFFAFAFA);

  List<Employee> _employees = [];

  @override
  void initState() {
    super.initState();
    _filteredEmployees = _employees;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _listController.forward();
    });

    _loadEmployees();
    _loadDepartments();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees(String query) {
    setState(() {
      _filteredEmployees = _employees
          .where(
            (employee) =>
                employee.fullName.toLowerCase().contains(query.toLowerCase()) ||
                employee.designation.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                employee.departmentName.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  Future<void> _loadEmployees() async {
    try {
      final response = await apiService.getAllEmployees();
      if (response['CONTENT'] is List) {
        setState(() {
          _employees = (response['CONTENT'] as List)
              .map((item) => Employee.fromJson(item))
              .toList();
          _filteredEmployees = _employees;
        });
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching employees: $e')));
      }
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await apiService.getAllDepartments();
      if (response['CONTENT'] is List) {
        setState(() {
          departments = (response['CONTENT'] as List)
              .map((item) => Department.fromJson(item))
              .toList();
        });
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching departments: $e')),
        );
      }
    }
  }

  void _addEmployee() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
    );
  }

  void _updateEmployee(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateEmployeeScreen(employee: employee),
      ),
    ).then((value) {
      if (value == "updated") {
        _loadEmployees();
      }
    });
  }

  void _deleteEmployee(int employeeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Employee',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to delete this employee?'),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: lightBlack)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                deleteEmployeeById(employeeId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteEmployeeById(int employeeId) async {
    try {
      final response = await apiService.deleteEmployee(employeeId);
      if (response['STS'] == '200') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee deleted successfully')),
        );
        _loadEmployees();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete employee: ${response['MSG']}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting employee: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlack,
      body: CustomScrollView(
        slivers: [
          _buildAnimatedHeader(),
          _buildSearchSection(),
          _buildStatsSection(),
          _buildEmployeeList(),
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
                        Icons.people_rounded,
                        size: 60 * _headerAnimation.value,
                        color: darkBlack,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Employee Directory',
                        style: TextStyle(
                          fontSize: 28 * _headerAnimation.value,
                          fontWeight: FontWeight.bold,
                          color: darkBlack,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Manage your team efficiently',
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

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lightBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryYellow.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search employees...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: Icon(Icons.search, color: primaryYellow),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(20),
          ),
          onChanged: _filterEmployees,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              lightYellow.withOpacity(0.9),
              primaryYellow.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryYellow.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', '${_employees.length}', Icons.people),
            _buildStatItem(
              'Active',
              '${_filteredEmployees.length}',
              Icons.work,
            ),
            _buildStatItem(
              'Depts',
              departments.length.toString(),
              Icons.business,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: darkBlack, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkBlack,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: darkBlack.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildEmployeeList() {
    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (_filteredEmployees.isEmpty) {
                return Container(
                  height: 200,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: lightBlack,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, color: Colors.white54, size: 50),
                        SizedBox(height: 10),
                        Text(
                          'No employees found',
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final employee = _filteredEmployees[index];
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _listAnimation.value)),
                child: Opacity(
                  opacity: _listAnimation.value,
                  child: EmployeeCard(
                    employee: employee,
                    onUpdate: () => _updateEmployee(employee),
                    onDelete: () => _deleteEmployee(employee.id),
                    index: index,
                  ),
                ),
              );
            },
            childCount: _filteredEmployees.isEmpty
                ? 1
                : _filteredEmployees.length,
          ),
        );
      },
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
        onPressed: _addEmployee,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.person_add_alt_1, color: darkBlack),
        label: const Text(
          'Add Employee',
          style: TextStyle(color: darkBlack, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class EmployeeCard extends StatefulWidget {
  final Employee employee;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final int index;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onUpdate,
    required this.onDelete,
    required this.index,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _cardController.forward(),
            onTapUp: (_) => _cardController.reverse(),
            onTapCancel: () => _cardController.reverse(),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _EmployeeListScreenState.primaryYellow.withOpacity(
                      0.1,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          _EmployeeListScreenState.lightYellow.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildEmployeeHeader(),
                              if (_isExpanded) ...[
                                const SizedBox(height: 20),
                                _buildEmployeeDetails(),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _EmployeeListScreenState.primaryYellow,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _EmployeeListScreenState.primaryYellow.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 35,
            backgroundColor: _EmployeeListScreenState.lightYellow,
            backgroundImage: NetworkImage(widget.employee.profilePic),
            child: widget.employee.profilePic.isEmpty
                ? Icon(
                    Icons.person,
                    color: _EmployeeListScreenState.darkBlack,
                    size: 35,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.employee.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _EmployeeListScreenState.primaryYellow.withOpacity(
                    0.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.employee.designation,
                  style: TextStyle(
                    fontSize: 14,
                    color: _EmployeeListScreenState.darkYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: _EmployeeListScreenState.lightBlack,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.employee.departmentName,
                    style: TextStyle(
                      fontSize: 14,
                      color: _EmployeeListScreenState.lightBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            _buildActionButton(
              icon: Icons.edit_rounded,
              color: Colors.blue,
              onPressed: widget.onUpdate,
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.delete_rounded,
              color: Colors.red,
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeeDetails() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _EmployeeListScreenState.primaryYellow.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailRow(Icons.email_rounded, 'Email', widget.employee.email),
        _buildDetailRow(Icons.phone_rounded, 'Phone', widget.employee.phoneNo),
        _buildDetailRow(
          Icons.location_on_rounded,
          'Address',
          widget.employee.address,
        ),
        _buildDetailRow(
          Icons.calendar_today_rounded,
          'Joined',
          DateFormat('MMM dd, yyyy').format(widget.employee.joiningDate),
        ),
        _buildDetailRow(
          Icons.attach_money_rounded,
          'Salary',
          '\$${NumberFormat('#,###').format(widget.employee.salary)}',
        ),
        _buildDetailRow(
          Icons.access_time_rounded,
          'Shift',
          '${widget.employee.shiftStartTime} - ${widget.employee.shiftEndTime}',
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _EmployeeListScreenState.primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: _EmployeeListScreenState.darkYellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _EmployeeListScreenState.lightBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
