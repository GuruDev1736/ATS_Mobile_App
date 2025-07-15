import 'package:ata_mobile/DioService/api_service.dart';
import 'package:ata_mobile/Utilities/SharedPrefManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _designationController = TextEditingController();

  // State variables
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isDataLoading = true;
  bool _hasInitialized = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // User data
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _getUserById();
    }
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
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  Future<void> _getUserById() async {
    try {
      setState(() => _isDataLoading = true);

      final int? userId = await SharedPrefManager().getInt(
        SharedPrefManager.userIdKey,
      );

      if (userId == null || userId == 0) {
        throw Exception('User ID not found');
      }

      final response = await ApiService().getUserById(userId);

      if (response != null && mounted) {
        setState(() {
          _userData = response['CONTENT'];
          _loadUserData();
          _isDataLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDataLoading = false);
        _showErrorSnackBar('Error fetching user data: $e');
      }
    }
  }

  void _loadUserData() {
    if (_userData.isNotEmpty) {
      _nameController.text = _userData['fullName'] ?? '';
      _emailController.text = _userData['email'] ?? '';
      _phoneController.text = _userData['phoneNo'] ?? '';
      _addressController.text = _userData['address'] ?? '';
      _designationController.text = _userData['designation'] ?? '';
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create updated user data
      final updatedData = {
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNo': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'designation': _designationController.text.trim(),
      };

      // Simulate API call for now - uncomment when API is ready
      await Future.delayed(const Duration(seconds: 2));

      // Update local user data
      setState(() {
        _userData.addAll(updatedData);
        _isEditing = false;
      });

      _showSuccessDialog();

      // TODO: Uncomment when API is ready
      // final int? userId = await SharedPrefManager().getInt(SharedPrefManager.userIdKey);
      // if (userId != null) {
      //   final response = await ApiService().updateUserProfile(userId, updatedData);
      //
      //   if (response['success'] == true) {
      //     setState(() {
      //       _userData.addAll(updatedData);
      //       _isEditing = false;
      //     });
      //     _showSuccessDialog();
      //   } else {
      //     throw Exception(response['message'] ?? 'Failed to update profile');
      //   }
      // }
    } catch (e) {
      _showErrorSnackBar('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile Updated!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkBlack,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your profile has been updated successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isDataLoading
          ? _buildLoadingScreen()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          _buildProfileHeader(),
                          const SizedBox(height: 20),
                          _buildQuickActions(),
                          const SizedBox(height: 20),
                          _buildProfileForm(),
                          const SizedBox(height: 20),
                          _buildAdditionalInfo(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
              boxShadow: [
                BoxShadow(
                  color: primaryYellow.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading Profile...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 80,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    lightYellow.withOpacity(0.4),
                    primaryYellow.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: primaryYellow.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryYellow.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    _userData['fullName'] ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkBlack,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryYellow, darkYellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: darkYellow.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _userData['designation'] ?? 'Designation',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryYellow.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryYellow.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.business_rounded,
                            size: 14,
                            color: darkYellow,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _userData['department'] != null &&
                                  _userData['department']['departmentName'] !=
                                      null
                              ? _userData['department']['departmentName']
                              : 'Department',
                          style: const TextStyle(
                            fontSize: 14,
                            color: darkBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusIndicator(
                        icon: Icons.verified_rounded,
                        label: 'Verified',
                        color: Colors.green,
                      ),
                      _buildStatusIndicator(
                        icon: Icons.trending_up_rounded,
                        label: 'Active',
                        color: Colors.blue,
                      ),
                      _buildStatusIndicator(
                        icon: Icons.security_rounded,
                        label: 'Secure',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Profile image
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [primaryYellow, darkYellow],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryYellow.withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: primaryYellow.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: lightYellow.withOpacity(0.3),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (_userData['profile_pic'] != null &&
                                            _userData['profile_pic'].isNotEmpty
                                        ? NetworkImage(_userData['profile_pic'])
                                        : null)
                                    as ImageProvider?,
                          child:
                              (_profileImage == null &&
                                  (_userData['profile_pic'] == null ||
                                      _userData['profile_pic'].isEmpty))
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: darkYellow,
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryYellow, darkYellow],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: darkYellow.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
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
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.schedule_rounded,
              title: 'Work Hours',
              subtitle:
                  '${_userData['shiftStartTime'] ?? '09:00'} - ${_userData['shiftEndTime'] ?? '17:00'}',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              icon: Icons.badge_rounded,
              title: 'Employee ID',
              subtitle: _userData['id'].toString() ?? 'N/A',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkBlack,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_rounded, color: primaryYellow),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFormField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              enabled: _isEditing,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your email';
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Please enter your phone number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on_outlined,
              enabled: _isEditing,
              maxLines: 2,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your address';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _designationController,
              label: 'Designation',
              icon: Icons.work_outline,
              enabled: _isEditing,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Please enter your designation';
                return null;
              },
            ),
            if (_isEditing) ...[
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _loadUserData(); // Reset form
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: enabled ? darkBlack : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? primaryYellow : Colors.grey[400],
        ),
        labelStyle: TextStyle(color: enabled ? darkBlack : Colors.grey[500]),
        filled: true,
        fillColor: enabled ? lightYellow.withOpacity(0.1) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryYellow.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryYellow),
              const SizedBox(width: 8),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Joining Date',
            value: _userData['joiningDate'] != null
                ? DateFormat(
                    'MMM dd, yyyy',
                  ).format(DateTime.parse(_userData['joiningDate']))
                : 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.attach_money_rounded,
            label: 'Salary',
            value: _userData['salary'] != null
                ? '\$${NumberFormat('#,###').format(_userData['salary'])}'
                : 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Work Schedule',
            value:
                '${_userData['shiftStartTime'] ?? '09:00'} - ${_userData['shiftEndTime'] ?? '17:00'}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: darkYellow),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: darkBlack,
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
