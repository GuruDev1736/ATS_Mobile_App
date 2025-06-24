import 'package:ata_mobile/DioService/api_service.dart';
import 'package:ata_mobile/Screens/Auth/sendOTP.dart';
import 'package:ata_mobile/Screens/Dashboard/DashboardScreen.dart';
import 'package:ata_mobile/Utilities/SharedPrefManager.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Reduced animations for better performance
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ApiService _authService = ApiService();
  SharedPrefManager sharedPrefManager = SharedPrefManager();

  // Custom Colors matching your theme
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);
  static const Color cardWhite = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    loadCredentials();
  }

  void _initializeAnimations() {
    // Simplified animations for better performance
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void loadCredentials() async {
    String? email = await sharedPrefManager.getString(
      SharedPrefManager.userEmailKey,
    );
    String? password = await sharedPrefManager.getString(
      SharedPrefManager.userPasswordKey,
    );

    _rememberMe = await sharedPrefManager.getBool(
      SharedPrefManager.rememberMeKey,
    );

    if (mounted) {
      setState(() {
        _emailController.text = email ?? '';
        _passwordController.text = password ?? '';
      });
    }
  }

  void _showLoadingDialog() {
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
                    'Signing In...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: darkBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please wait while we authenticate',
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
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();

      try {
        final response = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (response['STS'] == '200') {
          final content = response['CONTENT'];
          final token = content['token'];
          final fullName = content['fullName'];
          final userId = content['userId'];
          final userRole = content['userRole'];
          final userProfilePicture = content['userProfilePic'];
          final checkInTime = content['isCheckIn'];
          final checkOutTime = content['isCheckOut'];

          print(userProfilePicture);

          // Store in SharedPreferences
          await sharedPrefManager.setString(
            SharedPrefManager.userTokenKey,
            "Bearer " + token,
          );
          await sharedPrefManager.setString(
            SharedPrefManager.userFullNameKey,
            fullName,
          );
          await sharedPrefManager.setInt(SharedPrefManager.userIdKey, userId);
          await sharedPrefManager.setString(
            SharedPrefManager.userRoleKey,
            userRole,
          );
          await sharedPrefManager.setString(
            SharedPrefManager.userProfileImageKey,
            userProfilePicture ?? '',
          );

          await sharedPrefManager.setString(
            SharedPrefManager.checkInTimeKey,
            checkInTime ?? '',
          );

          await sharedPrefManager.setString(
            SharedPrefManager.checkOutTimeKey,
            checkOutTime ?? '',
          );

          if (_rememberMe) {
            await sharedPrefManager.setString(
              SharedPrefManager.userEmailKey,
              _emailController.text.trim(),
            );
            await sharedPrefManager.setString(
              SharedPrefManager.userPasswordKey,
              _passwordController.text.trim(),
            );
            await sharedPrefManager.setBool(
              SharedPrefManager.rememberMeKey,
              true,
            );
          } else {
            await sharedPrefManager.setString(
              SharedPrefManager.userEmailKey,
              '',
            );
            await sharedPrefManager.setString(
              SharedPrefManager.userPasswordKey,
              '',
            );
            await sharedPrefManager.setBool(
              SharedPrefManager.rememberMeKey,
              false,
            );
          }

          _hideLoadingDialog();

          // Show success message
          _showSuccessDialog(fullName);
        } else {
          _hideLoadingDialog();
          _showErrorDialog(response['MSG'] ?? "Login failed");
        }
      } catch (e) {
        print("Login Error: $e");
        _hideLoadingDialog();
        _showErrorDialog("Login Failed: $e");
      }
    }
  }

  void _showSuccessDialog(String fullName) {
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
                'Welcome Back!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Hello $fullName',
                style: TextStyle(color: darkBlack.withOpacity(0.6)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardPage()),
                );
              },
              child: const Text(
                'Continue',
                style: TextStyle(color: primaryYellow),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
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
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Login Failed',
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
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkBlack, lightBlack, darkBlack.withOpacity(0.8)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60),

                          // Simplified Logo Section
                          _buildSimpleLogo(),

                          SizedBox(height: 30),

                          // Welcome Text
                          _buildWelcomeText(),

                          SizedBox(height: 40),

                          // Login Form
                          _buildLoginForm(),

                          Spacer(),

                          // Footer
                          _buildFooter(),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleLogo() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryYellow, darkYellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(Icons.account_circle, size: 60, color: darkBlack),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryYellow,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: primaryYellow.withOpacity(0.5),
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to continue your journey',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardWhite, cardWhite.withOpacity(0.95)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryYellow.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email Field
              _buildEmailField(),

              SizedBox(height: 20),

              // Password Field
              _buildPasswordField(),

              SizedBox(height: 16),

              // Remember Me & Forgot Password - Fixed layout
              _buildRememberMeRow(),

              SizedBox(height: 24),

              // Login Button
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: TextStyle(color: darkBlack),
      decoration: InputDecoration(
        labelText: 'Email Address',
        labelStyle: TextStyle(color: darkBlack.withOpacity(0.7)),
        prefixIcon: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryYellow, darkYellow]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.email_outlined, color: darkBlack, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: lightYellow.withOpacity(0.2),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryYellow, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: darkBlack),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: darkBlack.withOpacity(0.7)),
        prefixIcon: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryYellow, darkYellow]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.lock_outline, color: darkBlack, size: 20),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: darkYellow,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: lightYellow.withOpacity(0.2),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryYellow, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        // Remember me section - takes available space
        Expanded(
          flex: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                  activeColor: primaryYellow,
                  checkColor: darkBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  'Remember me',
                  style: TextStyle(
                    color: darkBlack.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Forgot password section - flexible
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: darkYellow,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryYellow, darkYellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'SIGN IN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkBlack,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          height: 1,
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                primaryYellow.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          '© 2024 ATA Mobile',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
      ],
    );
  }
}
