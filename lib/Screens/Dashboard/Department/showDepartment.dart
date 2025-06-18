import 'package:ata_mobile/DioService/api_service.dart';
import 'package:ata_mobile/Screens/Dashboard/Department/AddDepartment.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class Department {
  int id;
  String name;
  String description;

  Department({required this.id, required this.name, required this.description});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['departmentName'] ?? '',
      description: json['departmentDescription'] ?? '',
    );
  }
}

class DepartmentsListScreen extends StatefulWidget {
  const DepartmentsListScreen({super.key});

  @override
  State<DepartmentsListScreen> createState() => _DepartmentsListScreenState();
}

class _DepartmentsListScreenState extends State<DepartmentsListScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _fabController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _fabAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);
  static const Color cardWhite = Color(0xFFFAFAFA);

  // Sample departments data for demo
  List<Department> departments = [];

  ApiService apiService = ApiService();

  List<Department> filteredDepartments = [];
  TextEditingController searchController = TextEditingController();

  void _filterDepartments(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDepartments = departments;
      } else {
        filteredDepartments = departments
            .where(
              (dept) =>
                  dept.name.toLowerCase().contains(query.toLowerCase()) ||
                  dept.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    filteredDepartments = departments;
    _initAnimations();
    _loadDepartments();
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
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _fabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await apiService.getAllDepartments();
      if (response['CONTENT'] is List) {
        setState(() {
          departments = (response['CONTENT'] as List)
              .map((item) => Department.fromJson(item))
              .toList();

          filteredDepartments = List.from(departments);
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

  void _deleteDepartment(int id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(
              24,
              0,
              24,
              24,
            ), // Add this line
            title: Column(
              mainAxisSize: MainAxisSize.min, // Add this line
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // Reduced from 16 to 12
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 28, // Keep this size for warning icon
                  ),
                ),
                const SizedBox(height: 12), // Reduced from 16 to 12
                const Text(
                  'Delete Department',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ), // Reduced from 20 to 18
                ),
              ],
            ),
            content: SizedBox(
              width:
                  MediaQuery.of(context).size.width *
                  0.8, // Add width constraint
              child: const Text(
                'Are you sure you want to delete this department? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15), // Reduced from 16 to 15
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 8), // Add some top padding
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ), // Reduced from 12 to 10
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: darkBlack),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          deleteDepartment(id);
                          Navigator.pop(
                            context,
                          ); // Close the dialog after deletion
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ), // Reduced from 12 to 10
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteDepartment(int id) async {
    try {
      final response = await apiService.deleteDepartment(id);
      if (response['STS'] == '200') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Department deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
        _loadDepartments(); // Refresh the list after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete department: ${response['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      throw Exception('Error deleting department: $e');
    }
  }

  void _updateDepartment(Department department) {
    final nameController = TextEditingController(text: department.name);
    final descController = TextEditingController(text: department.description);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(
              24,
              0,
              24,
              24,
            ), // Add this line
            title: Column(
              mainAxisSize: MainAxisSize.min, // Add this line
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // Reduced from 16 to 12
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryYellow, darkYellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 24, // Reduced from 28 to 24
                  ),
                ),
                const SizedBox(height: 12), // Reduced from 16 to 12
                const Text(
                  'Update Department',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ), // Reduced from 20 to 18
                ),
              ],
            ),
            content: SizedBox(
              width:
                  MediaQuery.of(context).size.width *
                  0.8, // Add width constraint
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Add this line
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: lightYellow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryYellow.withOpacity(0.5),
                        ),
                      ),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Department Name',
                          labelStyle: TextStyle(
                            color: darkBlack.withOpacity(0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.business_rounded,
                            color: darkYellow,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(
                            14,
                          ), // Reduced from 16 to 14
                        ),
                      ),
                    ),
                    const SizedBox(height: 14), // Reduced from 16 to 14
                    Container(
                      decoration: BoxDecoration(
                        color: lightYellow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryYellow.withOpacity(0.5),
                        ),
                      ),
                      child: TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(
                            color: darkBlack.withOpacity(0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.description_rounded,
                            color: darkYellow,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(
                            14,
                          ), // Reduced from 16 to 14
                        ),
                        maxLines: 2, // Reduced from 3 to 2
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 8), // Add some top padding
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: darkBlack),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryYellow, darkYellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ), // Reduced from 12 to 10
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            final title = nameController.text.trim();
                            final description = descController.text.trim();

                            if (title.isEmpty || description.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please fill in all fields',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            updateDepartment(department.id, title, description);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateDepartment(
    int id,
    String title,
    String description,
  ) async {
    try {
      final response = await apiService.updateDepartment(
        id,
        title,
        description,
      );
      if (response['STS'] == '200') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Department updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDepartments(); // Refresh the list after update
        Navigator.pop(context); // Close the dialog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update department: ${response['MSG']}'),
            backgroundColor: Colors.red,
          ),
        );
        _loadDepartments(); // Refresh the list after update
        Navigator.pop(context); // Close the dialog
      }
    } catch (e) {
      throw Exception('Error updating department: $e');
    }
  }

  void _addDepartment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDepartmentScreen()),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
          _buildSearchSection(),
          _buildStatsSection(),
          _buildDepartmentList(),
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
                child: SafeArea(
                  // Add SafeArea here
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ), // Reduced vertical padding
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // Add this line
                      children: [
                        const SizedBox(height: 20), // Reduced from 40 to 20
                        Icon(
                          Icons.business_center_rounded,
                          size:
                              50 *
                              _headerAnimation.value, // Reduced from 60 to 50
                          color: darkBlack,
                        ),
                        const SizedBox(height: 8), // Reduced from 10 to 8
                        Flexible(
                          // Wrap with Flexible
                          child: Text(
                            'Department Management',
                            style: TextStyle(
                              fontSize:
                                  24 *
                                  _headerAnimation
                                      .value, // Reduced from 28 to 24
                              fontWeight: FontWeight.bold,
                              color: darkBlack,
                              letterSpacing: 1.0, // Reduced from 1.2 to 1.0
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2, // Add maxLines
                            overflow:
                                TextOverflow.ellipsis, // Add overflow handling
                          ),
                        ),
                        const SizedBox(height: 4), // Reduced spacing
                        Flexible(
                          // Wrap with Flexible
                          child: Text(
                            'Organize and manage departments',
                            style: TextStyle(
                              fontSize:
                                  14 *
                                  _headerAnimation
                                      .value, // Reduced from 16 to 14
                              color: darkBlack.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1, // Add maxLines
                            overflow:
                                TextOverflow.ellipsis, // Add overflow handling
                          ),
                        ),
                      ],
                    ),
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
          boxShadow: [
            BoxShadow(
              color: primaryYellow.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: _filterDepartments,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search departments...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryYellow, darkYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      _filterDepartments('');
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(20),
          ),
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
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: darkBlack,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filteredDepartments.length} Active Departments',
                    style: const TextStyle(
                      color: darkBlack,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage organizational structure',
                    style: TextStyle(
                      color: darkBlack.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentList() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        if (filteredDepartments.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 300,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightBlack,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryYellow.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primaryYellow.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No departments found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search criteria',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final department = filteredDepartments[index];
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _cardAnimation.value)),
              child: Opacity(
                opacity: _cardAnimation.value,
                child: DepartmentCard(
                  department: department,
                  onUpdate: () => _updateDepartment(department),
                  onDelete: () => _deleteDepartment(department.id),
                  index: index,
                ),
              ),
            );
          }, childCount: filteredDepartments.length),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: Container(
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
              onPressed: _addDepartment,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add_business_rounded, color: Colors.white),
              label: const Text(
                'Add Department',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DepartmentCard extends StatefulWidget {
  final Department department;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final int index;

  const DepartmentCard({
    super.key,
    required this.department,
    required this.onUpdate,
    required this.onDelete,
    required this.index,
  });

  @override
  State<DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<DepartmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFFF5722),
      const Color(0xFF607D8B),
    ];
    final departmentColor = colors[widget.index % colors.length];

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _cardController.forward(),
            onTapUp: (_) => _cardController.reverse(),
            onTapCancel: () => _cardController.reverse(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFFFFF59D).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.1),
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
                          Colors.white.withOpacity(0.9),
                          const Color(0xFFFFF59D).withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header with gradient
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                departmentColor.withOpacity(0.1),
                                departmentColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      departmentColor,
                                      departmentColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: departmentColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.business_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.department.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: departmentColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Active Department',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: departmentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.department.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: const Color(
                                    0xFF1A1A1A,
                                  ).withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFFFFC107,
                                            ).withOpacity(0.1),
                                            const Color(
                                              0xFFFF8F00,
                                            ).withOpacity(0.05),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFFFC107,
                                          ).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: widget.onUpdate,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.edit_rounded,
                                                  color: Color(0xFFFF8F00),
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Update',
                                                  style: TextStyle(
                                                    color: Color(0xFFFF8F00),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red.withOpacity(0.1),
                                            Colors.red.withOpacity(0.05),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: widget.onDelete,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.delete_rounded,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
}
