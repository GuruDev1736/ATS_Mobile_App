import 'dart:convert';

import 'package:ata_mobile/DioService/api_service.dart';
import 'package:ata_mobile/Utilities/color_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
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

class Office {
  final int id;
  final String name;

  Office({required this.id, required this.name});

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(id: json['id'], name: json['officeName'] ?? '');
  }
}

class AddEmployeeScreen extends StatefulWidget {
  final String postion;

  const AddEmployeeScreen({super.key, required this.postion});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  ApiService apiService = ApiService();

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _salaryController = TextEditingController();
  final _designationController = TextEditingController();

  // Form data
  File? _profilePicture;
  String imageUrl = '';
  DateTime? _joiningDate;
  TimeOfDay? _shiftStartTime;
  TimeOfDay? _shiftEndTime;
  int? _selectedDepartmentId;
  int? _selectedOfficeId;
  bool _obscurePassword = true;
  int _currentStep = 0;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF212121);
  static const Color lightBlack = Color(0xFF424242);

  List<Department> departments = [];
  List<Office> offices = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDepartments();
    _loadOffice();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> _loadOffice() async {
    try {
      final response = await apiService.getAllOffices();
      if (response['CONTENT'] is List) {
        setState(() {
          offices = (response['CONTENT'] as List)
              .map((item) => Office.fromJson(item))
              .toList();
        });
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching offices: $e')));
      }
    }
  }

  void _pickImage() async {
    try {
      // Request camera and photo permissions
      final cameraPermission = await Permission.camera.request();

      if (cameraPermission.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Camera and photo permissions are required'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      // Show image source selection dialog
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Select Image Source',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBlack,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageSourceOption(
                              icon: Icons.camera_alt,
                              label: 'Camera',
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromSource(ImageSource.camera);
                              },
                            ),
                            _buildImageSourceOption(
                              icon: Icons.photo_library,
                              label: 'Gallery',
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromSource(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
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
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera/gallery: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryYellow,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _joiningDate = picked;
      });
    }
  }

  void _pickTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryYellow,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkBlack,
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

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      // Validate additional fields
      if (_joiningDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select joining date')),
        );
        return;
      }
      if (_shiftStartTime == null || _shiftEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select shift times')),
        );
        return;
      }
      if (_selectedDepartmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a department')),
        );
        return;
      }
      if (_selectedOfficeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an office')),
        );
        return;
      }

      if (widget.postion == "HR") {
        final response = await apiService.createHR(
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
          _phoneController.text,
          _addressController.text,
          imageUrl,
          _joiningDate!.toIso8601String(),
          int.parse(_salaryController.text),
          _designationController.text,
          _shiftStartTime!.format(context),
          _shiftEndTime!.format(context),
          _selectedDepartmentId!,
          _selectedOfficeId!,
        );

        if (response['STS'] == '200') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['MSG'] ?? response['error']),
              backgroundColor: primaryYellow,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else if (widget.postion == "Manager") {
        final response = await apiService.createManager(
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
          _phoneController.text,
          _addressController.text,
          imageUrl,
          _joiningDate!.toIso8601String(),
          int.parse(_salaryController.text),
          _designationController.text,
          _shiftStartTime!.format(context),
          _shiftEndTime!.format(context),
          _selectedDepartmentId!,
          _selectedOfficeId!,
        );

        if (response['STS'] == '200') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['MSG'] ?? response['error']),
              backgroundColor: primaryYellow,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true); // Close the screen after saving
        }
      } else if (widget.postion == "EMP") {
        final response = await apiService.createUser(
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
          _phoneController.text,
          _addressController.text,
          imageUrl,
          _joiningDate!.toIso8601String(),
          int.parse(_salaryController.text),
          _designationController.text,
          _shiftStartTime!.format(context),
          _shiftEndTime!.format(context),
          _selectedDepartmentId!,
          _selectedOfficeId!,
        );

        if (response['STS'] == '200') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['MSG'] ?? response['error']),
              backgroundColor: primaryYellow,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true); // Close the screen after saving
        }
      }
    }
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
          color: lightYellow.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryYellow.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            SizedBox(height: 12),
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

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscureText,
        validator: validator,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: darkBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: darkYellow, size: 20),
          ),
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(
            color: darkBlack.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(color: darkBlack.withOpacity(0.4)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryYellow, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: lightYellow.withOpacity(0.3),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: primaryYellow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: primaryYellow.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _profilePicture != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(57),
                      child: Image.file(_profilePicture!, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.person_add_rounded,
                      size: 48,
                      color: darkYellow,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to add profile picture',
            style: TextStyle(
              fontSize: 14,
              color: darkBlack.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      children: [
        // Joining Date
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: darkYellow,
                size: 20,
              ),
            ),
            title: Text(
              _joiningDate != null
                  ? 'Joining Date: ${_joiningDate!.day}/${_joiningDate!.month}/${_joiningDate!.year}'
                  : 'Select Joining Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _joiningDate != null
                    ? darkBlack
                    : darkBlack.withOpacity(0.6),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _pickDate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // Shift Times
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: darkYellow,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _shiftStartTime != null
                        ? 'Start: ${_shiftStartTime!.format(context)}'
                        : 'Start Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _shiftStartTime != null
                          ? darkBlack
                          : darkBlack.withOpacity(0.6),
                    ),
                  ),
                  onTap: () => _pickTime(true),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time_filled,
                      color: darkYellow,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _shiftEndTime != null
                        ? 'End: ${_shiftEndTime!.format(context)}'
                        : 'End Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _shiftEndTime != null
                          ? darkBlack
                          : darkBlack.withOpacity(0.6),
                    ),
                  ),
                  onTap: () => _pickTime(false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedDepartmentId,
        decoration: InputDecoration(
          labelText: 'Department',
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_center,
              color: darkYellow,
              size: 20,
            ),
          ),
          labelStyle: TextStyle(
            color: darkBlack.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryYellow, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        items: departments.map((department) {
          return DropdownMenuItem<int>(
            value: department.id,
            child: Text(
              department.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: darkBlack,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDepartmentId = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a department';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOfficeDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedOfficeId,
        decoration: InputDecoration(
          labelText: 'Office',
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_center,
              color: darkYellow,
              size: 20,
            ),
          ),
          labelStyle: TextStyle(
            color: darkBlack.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryYellow, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        items: offices.map((office) {
          return DropdownMenuItem<int>(
            value: office.id,
            child: Text(
              office.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: darkBlack,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedOfficeId = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select an office';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: List.generate(3, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? primaryYellow : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? primaryYellow : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: darkYellow, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter basic employee details',
            style: TextStyle(fontSize: 16, color: darkBlack.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),

          _buildProfilePictureSection(),

          _buildCustomTextField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter employee full name',
            icon: Icons.person_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter full name';
              }
              return null;
            },
          ),

          _buildCustomTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter email address',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email address';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          _buildCustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter password',
            icon: Icons.lock_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: darkBlack.withOpacity(0.6),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          _buildCustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter phone number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Address & Schedule',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set work schedule and address',
            style: TextStyle(fontSize: 16, color: darkBlack.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),

          _buildCustomTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter complete address',
            icon: Icons.location_on_rounded,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
          ),

          _buildDateTimeSection(),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Job Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete job details',
            style: TextStyle(fontSize: 16, color: darkBlack.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),

          _buildCustomTextField(
            controller: _salaryController,
            label: 'Salary',
            hint: 'Enter salary amount',
            icon: Icons.attach_money_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter salary';
              }
              return null;
            },
          ),

          _buildCustomTextField(
            controller: _designationController,
            label: 'Designation',
            hint: 'Enter job designation',
            icon: Icons.work_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter designation';
              }
              return null;
            },
          ),

          _buildDepartmentDropdown(),
          _buildOfficeDropdown(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lightYellow.withOpacity(0.3),
              Colors.white,
              lightYellow.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: darkBlack,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: primaryYellow,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Employee',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: darkBlack,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Step ${_currentStep + 1} of 3',
                              style: TextStyle(
                                fontSize: 14,
                                color: darkBlack.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Step Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStepIndicator(),
              ),

              // Form Content
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [_buildStep1(), _buildStep2(), _buildStep3()],
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: Container(
                          height: 56,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: lightBlack.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _previousStep,
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back, color: lightBlack),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Previous',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: lightBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Container(
                        height: 56,
                        margin: EdgeInsets.only(
                          left: _currentStep > 0 ? 12 : 0,
                        ),
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
                                // Validate current step before moving to next
                                if (_formKey.currentState!.validate()) {
                                  _nextStep();
                                }
                              } else {
                                _saveEmployee();
                              }
                            },
                            child: Center(
                              child: Text(
                                _currentStep < 2 ? 'Next' : 'Save',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
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
  }
}
