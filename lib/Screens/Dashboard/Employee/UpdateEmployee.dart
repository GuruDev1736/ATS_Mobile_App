import 'dart:convert';
import 'dart:io';
import 'package:ata_mobile/DioService/api_service.dart';
import 'package:ata_mobile/Screens/Dashboard/Employee/EmployeeList.dart';
import 'package:ata_mobile/Utilities/color_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';

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

class UpdateEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const UpdateEmployeeScreen({super.key, required this.employee});

  @override
  State<UpdateEmployeeScreen> createState() => _UpdateEmployeeScreenState();
}

class _UpdateEmployeeScreenState extends State<UpdateEmployeeScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _salaryController;
  late TextEditingController _designationController;

  // Form data
  File? _profilePicture;
  DateTime? _joiningDate;
  TimeOfDay? _shiftStartTime;
  TimeOfDay? _shiftEndTime;
  int? _selectedDepartmentId;
  int _currentStep = 0;
  ApiService apiService = ApiService();
  String imageUrl = '';

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _heroController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _heroAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF212121);
  static const Color lightBlack = Color(0xFF424242);

  List<Department> departments = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initAnimations();
    _loadDepartments();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(text: widget.employee.fullName);
    _emailController = TextEditingController(text: widget.employee.email);
    _phoneController = TextEditingController(text: widget.employee.phoneNo);
    _addressController = TextEditingController(text: widget.employee.address);
    _salaryController = TextEditingController(
      text: widget.employee.salary.toString(),
    );
    _designationController = TextEditingController(
      text: widget.employee.designation,
    );

    _joiningDate = widget.employee.joiningDate;
    _selectedDepartmentId = widget.employee.departmentId;
    imageUrl = widget.employee.profilePic;

    // Parse shift times
    _shiftStartTime = _parseTimeOfDay(widget.employee.shiftStartTime);
    _shiftEndTime = _parseTimeOfDay(widget.employee.shiftEndTime);
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts.length > 1 &&
          parts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _fadeController.forward();
    _heroController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _heroController.dispose();
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    _designationController.dispose();
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

  void _pickImage() async {
    try {
      final cameraPermission = await Permission.camera.request();

      if (cameraPermission.isDenied) {
        _showSnackBar('Camera permission is required', Colors.red);
        return;
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, lightYellow.withOpacity(0.3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: SafeArea(
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: primaryYellow,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Update Profile Picture',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkBlack,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageSourceOption(
                              icon: Icons.camera_alt_rounded,
                              label: 'Camera',
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromSource(ImageSource.camera);
                              },
                            ),
                            _buildImageSourceOption(
                              icon: Icons.photo_library_rounded,
                              label: 'Gallery',
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromSource(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      _showSnackBar('Error accessing camera/gallery: $e', Colors.red);
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profilePicture = File(image.path);
        });

        imageUrl = (await uploadImageToCloudinary(_profilePicture!))!;
        print('Image URL: $imageUrl');
        if (imageUrl.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture uploaded successfully!'),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', Colors.red);
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dvkr3uadb';
    const uploadPreset = 'taskease';

    final mimeTypeData = lookupMimeType(imageFile.path)?.split('/');

    final imageUploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );

    final file = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: DioMediaType(mimeTypeData![0], mimeTypeData[1]),
    );

    imageUploadRequest.files.add(file);
    imageUploadRequest.fields['upload_preset'] = uploadPreset;

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['secure_url']; // <-- This is the Cloudinary image URL
      } else {
        print('Cloudinary upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryYellow,
              onPrimary: darkBlack,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _joiningDate) {
      setState(() {
        _joiningDate = picked;
      });
    }
  }

  void _pickTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_shiftStartTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_shiftEndTime ?? const TimeOfDay(hour: 17, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryYellow,
              onPrimary: darkBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _shiftStartTime = picked;
        } else {
          _shiftEndTime = picked;
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      final response = await apiService.updateEmployee(
        widget.employee.id,
        _fullNameController.text,
        _emailController.text,
        _phoneController.text,
        _addressController.text,
        imageUrl.isEmpty ? widget.employee.profilePic : imageUrl,
        _joiningDate.toString(),
        double.parse(_salaryController.text).toInt(),
        _designationController.text,
        _shiftStartTime!.format(context),
        _shiftEndTime!.format(context),
        _selectedDepartmentId!,
      );

      if (response['STS'] == '200') {
        _showSnackBar('Employee updated successfully!', AppColors.primaryGreen);
        Navigator.pop(context, 'updated');
      } else {
        _showSnackBar(
          'Failed to update employee: ${response['MSG']}',
          Colors.red,
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlack,
      body: Column(
        children: [
          _buildAnimatedHeader(),
          _buildStepIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [_buildStep1(), _buildStep2(), _buildStep3()],
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryYellow, darkYellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Update Employee',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                  const SizedBox(height: 20),
                  Transform.scale(
                    scale: _heroAnimation.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded, color: Colors.white, size: 30),
                        const SizedBox(width: 10),
                        Text(
                          'Modify Employee Details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
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

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? primaryYellow
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['Personal', 'Professional', 'Schedule'][index],
                    style: TextStyle(
                      fontSize: 12,
                      color: index <= _currentStep
                          ? primaryYellow
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  'Personal Information',
                  Icons.person_rounded,
                ),
                const SizedBox(height: 20),
                _buildProfilePictureSection(),
                const SizedBox(height: 25),
                _buildCustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter full name' : null,
                ),
                const SizedBox(height: 20),
                _buildCustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter email';
                    if (!value.contains('@')) return 'Please enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildCustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter phone number' : null,
                ),
                const SizedBox(height: 20),
                _buildCustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter address' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  'Professional Details',
                  Icons.work_outline_rounded,
                ),
                const SizedBox(height: 20),
                _buildCustomTextField(
                  controller: _designationController,
                  label: 'Designation',
                  icon: Icons.badge_outlined,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter designation' : null,
                ),
                const SizedBox(height: 20),
                _buildCustomTextField(
                  controller: _salaryController,
                  label: 'Salary',
                  icon: Icons.attach_money_outlined,
                  keyboardType: TextInputType.number,

                  validator: (value) =>
                      value!.isEmpty ? 'Please enter salary' : null,
                ),
                const SizedBox(height: 20),
                _buildDepartmentDropdown(),
                const SizedBox(height: 20),
                _buildDateField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Work Schedule', Icons.schedule_rounded),
                const SizedBox(height: 20),
                _buildTimeField('Shift Start Time', _shiftStartTime, true),
                const SizedBox(height: 20),
                _buildTimeField('Shift End Time', _shiftEndTime, false),
                const SizedBox(height: 30),
                _buildSummaryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryYellow.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryYellow, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryYellow, width: 4),
            boxShadow: [
              BoxShadow(
                color: primaryYellow.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: lightYellow,
            backgroundImage: _profilePicture != null
                ? FileImage(_profilePicture!)
                : (imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null)
                      as ImageProvider?,
            child: _profilePicture == null && imageUrl.isEmpty
                ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: lightBlack.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: primaryYellow),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: lightBlack.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedDepartmentId,
        style: const TextStyle(color: Colors.white),
        dropdownColor: lightBlack,
        decoration: InputDecoration(
          labelText: 'Department',
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(Icons.business_outlined, color: primaryYellow),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        items: departments
            .map(
              (dept) => DropdownMenuItem(
                value: dept.id,
                child: Text(
                  dept.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedDepartmentId = value;
          });
        },
        validator: (value) => value == null ? 'Please select department' : null,
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lightBlack.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryYellow.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: primaryYellow),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Joining Date',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _joiningDate != null
                        ? '${_joiningDate!.day}/${_joiningDate!.month}/${_joiningDate!.year}'
                        : 'Select joining date',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time, bool isStartTime) {
    return GestureDetector(
      onTap: () => _pickTime(isStartTime),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lightBlack.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryYellow.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_outlined, color: primaryYellow),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time != null ? time.format(context) : 'Select time',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryYellow.withOpacity(0.1),
            darkYellow.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize_outlined, color: primaryYellow),
              const SizedBox(width: 8),
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Name', _fullNameController.text),
          _buildSummaryRow('Email', _emailController.text),
          _buildSummaryRow('Designation', _designationController.text),
          _buildSummaryRow(
            'Department',
            departments
                .firstWhere(
                  (dept) => dept.id == _selectedDepartmentId,
                  orElse: () =>
                      Department(id: 0, name: 'Not selected', description: ''),
                )
                .name,
          ),
          _buildSummaryRow('Salary', '\$${_salaryController.text}'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: lightYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryYellow.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryYellow.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: Container(
                height: 56,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryYellow),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _previousStep,
                    child: const Center(
                      child: Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: Container(
              height: 56,
              margin: EdgeInsets.only(left: _currentStep > 0 ? 10 : 0),
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
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (_currentStep < 2) {
                      if (_formKey.currentState!.validate()) {
                        _nextStep();
                      }
                    } else {
                      _updateEmployee();
                    }
                  },
                  child: Center(
                    child: Text(
                      _currentStep < 2 ? 'Next' : 'Update Employee',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
