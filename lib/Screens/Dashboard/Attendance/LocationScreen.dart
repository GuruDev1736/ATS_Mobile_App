import 'package:ata_mobile/DioService/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class LocationBasedAttendanceScreen extends StatefulWidget {
  final String employeeName;
  final int employeeId;

  const LocationBasedAttendanceScreen({
    super.key,
    required this.employeeName,
    required this.employeeId,
  });

  @override
  State<LocationBasedAttendanceScreen> createState() =>
      _LocationBasedAttendanceScreenState();
}

class _LocationBasedAttendanceScreenState
    extends State<LocationBasedAttendanceScreen>
    with TickerProviderStateMixin {
  // Controllers and Animations
  late GoogleMapController _mapController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _buttonController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _shakeAnimation;

  // Custom Colors
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);
  static const Color cardWhite = Color(0xFFFAFAFA);

  // Location variables
  Position? currentPosition;
  StreamSubscription<Position>? positionStream;

  // Office location (replace with your actual office coordinates)
  static const LatLng officeLocation = LatLng(
    18.48191926205389,
    73.94860021702955,
  );
  static const double allowedRadius = 10.0; // 10 meters

  bool isWithinOfficeRadius = false;
  bool isLocationLoading = true;
  bool isCheckedIn = false;
  bool isLocationServiceEnabled = false;
  bool hasLocationPermission = false;
  DateTime? checkInTime;
  String locationStatus = "Checking location...";
  double distanceFromOffice = 0.0;

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLocationServicesAndPermissions();
    _createMapMarkers();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _createMapMarkers() {
    // Office marker
    markers.add(
      Marker(
        markerId: const MarkerId('office'),
        position: officeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(
          title: 'Office Location',
          snippet: 'Your workplace',
        ),
      ),
    );

    // Office radius circle
    circles.add(
      Circle(
        circleId: const CircleId('office_radius'),
        center: officeLocation,
        radius: allowedRadius,
        fillColor: primaryYellow.withOpacity(0.2),
        strokeColor: primaryYellow,
        strokeWidth: 2,
      ),
    );
  }

  Future<void> _checkLocationServicesAndPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    setState(() {
      isLocationServiceEnabled = serviceEnabled;
    });

    if (!serviceEnabled) {
      setState(() {
        locationStatus = "Location services are disabled";
        isLocationLoading = false;
      });
      _showLocationServiceDialog();
      return;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          hasLocationPermission = false;
          locationStatus = "Location permissions are denied";
          isLocationLoading = false;
        });
        _showPermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        hasLocationPermission = false;
        locationStatus = "Location permissions are permanently denied";
        isLocationLoading = false;
      });
      _showPermissionDialog();
      return;
    }

    setState(() {
      hasLocationPermission = true;
    });

    _startLocationTracking();
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_off,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Location Services Disabled',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'Please enable GPS/Location services to use attendance check-in feature.',
                style: TextStyle(
                  fontSize: 14,
                  color: darkBlack.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: lightYellow.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: darkYellow, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Go to Settings > Location > Turn on GPS',
                        style: TextStyle(
                          fontSize: 12,
                          color: darkBlack.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: darkBlack.withOpacity(0.6)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _openLocationSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryYellow,
                foregroundColor: darkBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );

    // Start shake animation
    _shakeController.repeat(reverse: true);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_disabled,
                  color: Colors.orange,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Location Permission Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'This app needs location permission to verify your presence at the office for attendance check-in.',
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: darkBlack.withOpacity(0.6)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestLocationPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryYellow,
                foregroundColor: darkBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
      // Wait a bit and recheck
      await Future.delayed(const Duration(seconds: 2));
      _recheckLocationServices();
    } catch (e) {
      print('Error opening location settings: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Open app settings if permission is still denied
      await openAppSettings();
      await Future.delayed(const Duration(seconds: 2));
      _recheckLocationServices();
    } else {
      _recheckLocationServices();
    }
  }

  Future<void> _recheckLocationServices() async {
    setState(() {
      isLocationLoading = true;
      locationStatus = "Checking location...";
    });

    await _checkLocationServicesAndPermissions();
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Update every 1 meter
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _updateLocation(position);
          },
          onError: (error) {
            print('Location error: $error');
            setState(() {
              locationStatus = "Location error occurred";
              isLocationLoading = false;
            });
          },
        );
  }

  void _updateLocation(Position position) {
    setState(() {
      currentPosition = position;
      isLocationLoading = false;

      // Calculate distance from office
      distanceFromOffice = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLocation.latitude,
        officeLocation.longitude,
      );

      // Check if within allowed radius
      bool wasWithinRadius = isWithinOfficeRadius;
      isWithinOfficeRadius = distanceFromOffice <= allowedRadius;

      if (isWithinOfficeRadius) {
        locationStatus = "You're at the office! ✅";
        if (!wasWithinRadius) {
          _buttonController.forward();
        }
      } else {
        locationStatus =
            "${distanceFromOffice.toStringAsFixed(1)}m from office";
        if (wasWithinRadius) {
          _buttonController.reverse();
        }
      }
    });

    // Update user marker
    _updateUserMarker(position);
  }

  void _updateUserMarker(Position position) {
    markers.removeWhere((marker) => marker.markerId == const MarkerId('user'));
    markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: '${distanceFromOffice.toStringAsFixed(1)}m from office',
        ),
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    if (!isWithinOfficeRadius) return;

    final response = await ApiService().checkIn(widget.employeeId);
    if (response["STS"] == "200") {
      setState(() {
        isCheckedIn = true;
        checkInTime = DateTime.now();
      });
      _showSuccessDialog();
    } else {
      print("Check-in failed: ${response["MSG"]}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response["MSG"])));
      return;
    }
  }

  void _showSuccessDialog() {
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
                  gradient: RadialGradient(
                    colors: [
                      primaryYellow.withOpacity(0.3),
                      primaryYellow.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: primaryYellow,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Check-in Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Location verified at ${DateFormat('hh:mm a').format(DateTime.now())}',
                style: TextStyle(
                  color: darkBlack.withOpacity(0.6),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightYellow.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location, color: darkYellow, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${distanceFromOffice.toStringAsFixed(1)}m from office',
                      style: const TextStyle(
                        color: darkBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(
                  context,
                ).pop({"isCheckedIn": true}); // Return to previous screen
              },
              child: const Text(
                'Great!',
                style: TextStyle(color: primaryYellow, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _buttonController.dispose();
    _shakeController.dispose();
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlack,
      body: Stack(
        children: [
          // Google Map
          _buildGoogleMap(),

          // Top Header
          _buildHeader(),

          // Bottom Panel
          _buildBottomPanel(),

          // Check-in Button (only when in range)
          if (isWithinOfficeRadius &&
              !isCheckedIn &&
              hasLocationPermission &&
              isLocationServiceEnabled)
            _buildCheckInButton(),

          // Loading overlay
          if (isLocationLoading) _buildLoadingOverlay(),

          // Location disabled overlay
          if (!isLocationServiceEnabled || !hasLocationPermission)
            _buildLocationDisabledOverlay(),
        ],
      ),
    );
  }

  Widget _buildLocationDisabledOverlay() {
    return Container(
      color: darkBlack.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_off,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                !isLocationServiceEnabled
                    ? 'Location Services Disabled'
                    : 'Location Permission Required',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                !isLocationServiceEnabled
                    ? 'Please enable GPS/Location services in your device settings to use the attendance feature.'
                    : 'This app needs location permission to verify your presence at the office.',
                style: TextStyle(
                  fontSize: 14,
                  color: darkBlack.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Go Back',
                        style: TextStyle(color: darkBlack.withOpacity(0.6)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!isLocationServiceEnabled) {
                          await _openLocationSettings();
                        } else {
                          await _requestLocationPermission();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryYellow,
                        foregroundColor: darkBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        !isLocationServiceEnabled
                            ? 'Enable GPS'
                            : 'Grant Permission',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        if (currentPosition != null) {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
              18.0,
            ),
          );
        }
      },
      initialCameraPosition: const CameraPosition(
        target: officeLocation,
        zoom: 16.0,
      ),
      markers: markers,
      circles: circles,
      myLocationEnabled: hasLocationPermission && isLocationServiceEnabled,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      compassEnabled: true,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkBlack, darkBlack.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardWhite.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: darkBlack),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: cardWhite.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryYellow.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Check-in',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlack,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.employeeName,
                      style: TextStyle(
                        fontSize: 14,
                        color: darkBlack.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Status indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (!isLocationServiceEnabled || !hasLocationPermission) return Colors.red;
    if (isLocationLoading) return Colors.orange;
    if (isWithinOfficeRadius) return Colors.green;
    return Colors.orange;
  }

  IconData _getStatusIcon() {
    if (!isLocationServiceEnabled || !hasLocationPermission) {
      return Icons.location_off;
    }
    if (isLocationLoading) return Icons.location_searching;
    if (isWithinOfficeRadius) return Icons.location_on;
    return Icons.location_searching;
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: primaryYellow.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getStatusColor() == Colors.green
                      ? [
                          Colors.green.withOpacity(0.2),
                          Colors.green.withOpacity(0.1),
                        ]
                      : _getStatusColor() == Colors.red
                      ? [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.1),
                        ]
                      : [
                          Colors.orange.withOpacity(0.2),
                          Colors.orange.withOpacity(0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _getStatusColor(), width: 1),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isWithinOfficeRadius
                            ? _pulseAnimation.value
                            : 1.0,
                        child: Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                          size: 30,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationStatus,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                        if (!isWithinOfficeRadius &&
                            hasLocationPermission &&
                            isLocationServiceEnabled)
                          Text(
                            'Move closer to office to check in',
                            style: TextStyle(
                              fontSize: 12,
                              color: darkBlack.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Location info
            if (hasLocationPermission && isLocationServiceEnabled) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Distance',
                      '${distanceFromOffice.toStringAsFixed(1)}m',
                      Icons.straighten,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildInfoCard(
                      'Required',
                      '≤ ${allowedRadius.toInt()}m',
                      Icons.gps_fixed,
                    ),
                  ),
                ],
              ),
            ],

            if (isCheckedIn) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: lightYellow.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Checked In Successfully',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkBlack,
                            ),
                          ),
                          Text(
                            'At ${DateFormat('hh:mm a').format(checkInTime!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: darkBlack.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryYellow.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryYellow, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBlack,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: darkBlack.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton() {
    return Positioned(
      bottom: 280,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _buttonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 120 + (100 * _rippleAnimation.value),
                      height: 120 + (100 * _rippleAnimation.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryYellow.withOpacity(
                            0.6 - (0.6 * _rippleAnimation.value),
                          ),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
                // Main button
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [primaryYellow, darkYellow],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryYellow.withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(60),
                      onTap: _handleCheckIn,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fingerprint, color: darkBlack, size: 40),
                          SizedBox(height: 5),
                          Text(
                            'CHECK IN',
                            style: TextStyle(
                              color: darkBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: darkBlack.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryYellow),
              ),
              const SizedBox(height: 20),
              const Text(
                'Getting your location...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkBlack,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please wait while we verify your location',
                style: TextStyle(
                  fontSize: 12,
                  color: darkBlack.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
