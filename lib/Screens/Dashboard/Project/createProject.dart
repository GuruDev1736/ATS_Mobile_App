import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form Controllers
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  final TextEditingController _projectLogoController = TextEditingController();
  final TextEditingController _githubUrlController = TextEditingController();
  final TextEditingController _meetingUrlController = TextEditingController();
  final TextEditingController _projectTechStackController =
      TextEditingController();

  // Date Controllers
  DateTime? _startDate;
  DateTime? _endDate;

  // Dropdown Values
  String? _selectedStatus;
  String? _selectedProjectManager;
  String? _selectedTeamLead;
  String? _selectedDepartment;
  String? _selectedCreatedBy;
  String? _selectedUpdatedBy;

  // Dropdown Options
  final List<String> _statusOptions = [
    'Planning',
    'In Progress',
    'On Hold',
    'Completed',
    'Cancelled',
  ];

  final List<String> _userOptions = [
    'John Doe',
    'Jane Smith',
    'Mike Johnson',
    'Sarah Wilson',
    'David Brown',
  ];

  final List<String> _departmentOptions = [
    'Development',
    'Design',
    'Marketing',
    'Sales',
    'HR',
  ];

  final List<String> _techStackOptions = [
    'Flutter',
    'React Native',
    'Node.js',
    'Python',
    'Java',
    'Swift',
    'Kotlin',
    'Firebase',
    'MongoDB',
    'PostgreSQL',
  ];

  List<String> _selectedTechStack = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _projectLogoController.dispose();
    _githubUrlController.dispose();
    _meetingUrlController.dispose();
    _projectTechStackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Add New Project',
          style: TextStyle(
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
              icon: const Icon(Icons.help_outline, color: Colors.black),
              onPressed: () => _showHelpDialog(),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(),
                  const SizedBox(height: 30),

                  // Basic Information Section
                  _buildSectionTitle('Basic Information', Icons.info_outline),
                  const SizedBox(height: 15),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 30),

                  // Timeline Section
                  _buildSectionTitle('Project Timeline', Icons.schedule),
                  const SizedBox(height: 15),
                  _buildTimelineSection(),
                  const SizedBox(height: 30),

                  // Links Section
                  _buildSectionTitle('External Links', Icons.link),
                  const SizedBox(height: 15),
                  _buildLinksSection(),
                  const SizedBox(height: 30),

                  // Technology Section
                  _buildSectionTitle('Technology Stack', Icons.code),
                  const SizedBox(height: 15),
                  _buildTechnologySection(),
                  const SizedBox(height: 30),

                  // Team Section
                  _buildSectionTitle('Team Assignment', Icons.group),
                  const SizedBox(height: 15),
                  _buildTeamSection(),
                  const SizedBox(height: 30),

                  // Management Section
                  _buildSectionTitle(
                    'Project Management',
                    Icons.admin_panel_settings,
                  ),
                  const SizedBox(height: 15),
                  _buildManagementSection(),
                  const SizedBox(height: 40),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_circle_outline,
              size: 35,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Project',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details to create a new project and assign team members',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.yellow.shade700, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
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
        children: [
          _buildTextField(
            controller: _projectNameController,
            label: 'Project Name',
            icon: Icons.folder_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter project name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _projectDescriptionController,
            label: 'Project Description',
            icon: Icons.description_outlined,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter project description';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _projectLogoController,
            label: 'Project Logo URL',
            icon: Icons.image_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter project logo URL';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            value: _selectedStatus,
            label: 'Project Status',
            icon: Icons.flag_outlined,
            items: _statusOptions,
            onChanged: (value) => setState(() => _selectedStatus = value),
            validator: (value) {
              if (value == null) {
                return 'Please select project status';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
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
        children: [
          _buildDateField(
            label: 'Start Date',
            icon: Icons.calendar_today_outlined,
            selectedDate: _startDate,
            onDateSelected: (date) => setState(() => _startDate = date),
          ),
          const SizedBox(height: 20),
          _buildDateField(
            label: 'End Date',
            icon: Icons.event_outlined,
            selectedDate: _endDate,
            onDateSelected: (date) => setState(() => _endDate = date),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection() {
    return Container(
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
        children: [
          _buildTextField(
            controller: _githubUrlController,
            label: 'GitHub Repository URL',
            icon: Icons.code_outlined,
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  !value.contains('github.com')) {
                return 'Please enter a valid GitHub URL';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _meetingUrlController,
            label: 'Meeting URL',
            icon: Icons.video_call_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologySection() {
    return Container(
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
          const Text(
            'Select Technologies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _techStackOptions.map((tech) {
              final isSelected = _selectedTechStack.contains(tech);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTechStack.remove(tech);
                    } else {
                      _selectedTechStack.add(tech);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.yellow.shade400
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.yellow.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    tech,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
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
        children: [
          _buildDropdownField(
            value: _selectedProjectManager,
            label: 'Project Manager',
            icon: Icons.person_outlined,
            items: _userOptions,
            onChanged: (value) =>
                setState(() => _selectedProjectManager = value),
            validator: (value) {
              if (value == null) {
                return 'Please select a project manager';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            value: _selectedTeamLead,
            label: 'Team Lead',
            icon: Icons.person_pin_outlined,
            items: _userOptions,
            onChanged: (value) => setState(() => _selectedTeamLead = value),
            validator: (value) {
              if (value == null) {
                return 'Please select a team lead';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            value: _selectedDepartment,
            label: 'Department',
            icon: Icons.apartment_outlined,
            items: _departmentOptions,
            onChanged: (value) => setState(() => _selectedDepartment = value),
            validator: (value) {
              if (value == null) {
                return 'Please select a department';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection() {
    return Container(
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
        children: [
          _buildDropdownField(
            value: _selectedCreatedBy,
            label: 'Created By',
            icon: Icons.person_add_outlined,
            items: _userOptions,
            onChanged: (value) => setState(() => _selectedCreatedBy = value),
            validator: (value) {
              if (value == null) {
                return 'Please select who created this project';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            value: _selectedUpdatedBy,
            label: 'Updated By',
            icon: Icons.update_outlined,
            items: _userOptions,
            onChanged: (value) => setState(() => _selectedUpdatedBy = value),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.yellow.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.yellow.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(context, selectedDate, onDateSelected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.yellow.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(selectedDate)
                        : 'Select $label',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null
                          ? Colors.black
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade400, Colors.yellow.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade300.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
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
            const Icon(Icons.add_circle_outline, color: Colors.black, size: 24),
            const SizedBox(width: 10),
            const Text(
              'CREATE PROJECT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    void Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.yellow.shade600,
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        _showErrorDialog('Please select both start and end dates');
        return;
      }

      if (_selectedTechStack.isEmpty) {
        _showErrorDialog('Please select at least one technology');
        return;
      }

      // Create project object with all the data
      final projectData = {
        'projectName': _projectNameController.text,
        'projectDescription': _projectDescriptionController.text,
        'projectLogo': _projectLogoController.text,
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'status': _selectedStatus,
        'githubUrl': _githubUrlController.text,
        'meetingUrl': _meetingUrlController.text,
        'projectTechStack': _selectedTechStack.join(', '),
        'projectManager': _selectedProjectManager,
        'teamLead': _selectedTeamLead,
        'department': _selectedDepartment,
        'createdBy': _selectedCreatedBy,
        'updatedBy': _selectedUpdatedBy,
      };

      // TODO: Send project data to API
      print('Project Data: $projectData');

      _showSuccessDialog();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 10),
              const Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.yellow.shade700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 10),
              const Text('Success'),
            ],
          ),
          content: const Text('Project created successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.yellow.shade700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.yellow.shade700),
              const SizedBox(width: 10),
              const Text('Help'),
            ],
          ),
          content: const Text(
            'Fill in all the required fields to create a new project. '
            'Make sure to select appropriate team members and set realistic timelines.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(color: Colors.yellow.shade700),
              ),
            ),
          ],
        );
      },
    );
  }
}
