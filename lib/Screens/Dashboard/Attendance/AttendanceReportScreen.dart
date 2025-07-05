import 'package:flutter/material.dart';
import 'package:ata_mobile/DioService/api_service.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Add this import for base64 decoding
import 'package:open_file/open_file.dart'; // Add this import

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Custom Colors (matching your theme)
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);

  // State variables
  bool isLoadingToday = false;
  bool isLoadingMonthly = false;
  DateTime selectedDate = DateTime.now();
  String? todayReportStatus;
  String? monthlyReportStatus;

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
    super.dispose();
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 11+ (API 30+), request manage external storage permission
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // For older Android versions, request storage permission
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // Try to request manage external storage for Android 11+
      final manageStorageStatus = await Permission.manageExternalStorage
          .request();
      return manageStorageStatus.isGranted || storageStatus.isGranted;
    }

    // For iOS, no special permission needed for app documents directory
    return true;
  }

  // Download today's report
  Future<void> _downloadTodayReport() async {
    if (isLoadingToday) return;

    setState(() {
      isLoadingToday = true;
      todayReportStatus = null;
    });

    try {
      // Request permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get report data from API
      final response = await ApiService().getTodayAttendanceReport();

      if (response["STS"] == "200") {
        // Extract base64 data and filename
        final String base64Data = response["CONTENT"]["data"];
        final String fileName =
            response["CONTENT"]["filename"] ??
            'today_attendance_report_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.xlsx';

        // Convert base64 to bytes
        final Uint8List reportBytes = base64Decode(base64Data);

        // Save file to Documents folder
        await _saveFile(reportBytes, fileName);

        setState(() {
          todayReportStatus = 'Report downloaded successfully!';
        });
      } else {
        throw Exception(response["MSG"] ?? "Failed to generate report");
      }
    } catch (e) {
      setState(() {
        todayReportStatus = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingToday = false;
      });
    }
  }

  // Download monthly report
  Future<void> _downloadMonthlyReport() async {
    if (isLoadingMonthly) return;

    setState(() {
      isLoadingMonthly = true;
      monthlyReportStatus = null;
    });

    try {
      // Request permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get report data from API
      final response = await ApiService().getMonthlyAttendanceReport(
        selectedDate.month,
        selectedDate.year,
      );

      if (response["STS"] == "200") {
        // Extract base64 data and filename
        final String base64Data = response["CONTENT"]["data"];
        final String fileName =
            response["CONTENT"]["filename"] ??
            'monthly_attendance_report_${DateFormat('yyyy_MM').format(selectedDate)}.xlsx';

        // Convert base64 to bytes
        final Uint8List reportBytes = base64Decode(base64Data);

        // Save file to Documents folder
        await _saveFile(reportBytes, fileName);

        setState(() {
          monthlyReportStatus = 'Report downloaded successfully!';
        });
      } else {
        throw Exception(response["MSG"] ?? "Failed to generate report");
      }
    } catch (e) {
      setState(() {
        monthlyReportStatus = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingMonthly = false;
      });
    }
  }

  // Save file to Downloads folder
  Future<void> _saveFile(Uint8List bytes, String fileName) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        final directories = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        directory = directories?.first;
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        _showSuccessDialog(file.path);
      }
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  // Show month/year picker
  Future<void> _selectMonthYear() async {
    await showDialog(
      context: context,
      builder: (context) => _MonthYearPicker(
        initialDate: selectedDate,
        onDateSelected: (date) {
          setState(() {
            selectedDate = date;
            monthlyReportStatus = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlack,
      appBar: AppBar(
        title: const Text(
          'Attendance Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBlack,
        iconTheme: const IconThemeData(color: primaryYellow),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildTodayReportCard(),
                const SizedBox(height: 20),
                _buildMonthlyReportCard(),
                const SizedBox(height: 30),
                _buildInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryYellow.withOpacity(0.9), darkYellow.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.file_download_rounded,
              size: 40,
              color: darkBlack,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Download Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkBlack,
                  ),
                ),
                Text(
                  'Generate and download attendance reports',
                  style: TextStyle(
                    fontSize: 14,
                    color: darkBlack.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReportCard() {
    return Container(
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.today_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Today\'s Report',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Download today\'s attendance report (${DateFormat('MMM dd, yyyy').format(DateTime.now())})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoadingToday ? null : _downloadTodayReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryYellow,
                  foregroundColor: darkBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoadingToday) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: darkBlack,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Generating...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.download_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Download Today\'s Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (todayReportStatus != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: todayReportStatus!.contains('Error')
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      todayReportStatus!.contains('Error')
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: todayReportStatus!.contains('Error')
                          ? Colors.red
                          : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        todayReportStatus!,
                        style: TextStyle(
                          color: todayReportStatus!.contains('Error')
                              ? Colors.red
                              : Colors.green,
                          fontSize: 14,
                        ),
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

  Widget _buildMonthlyReportCard() {
    return Container(
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Monthly Report',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Download monthly attendance report for selected period',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            // Month/Year Selector
            Container(
              decoration: BoxDecoration(
                color: darkBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryYellow.withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _selectMonthYear,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range_rounded,
                          color: primaryYellow,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DateFormat('MMMM yyyy').format(selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoadingMonthly ? null : _downloadMonthlyReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryYellow,
                  foregroundColor: darkBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoadingMonthly) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: darkBlack,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Generating...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.download_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Download Monthly Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (monthlyReportStatus != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: monthlyReportStatus!.contains('Error')
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      monthlyReportStatus!.contains('Error')
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: monthlyReportStatus!.contains('Error')
                          ? Colors.red
                          : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        monthlyReportStatus!,
                        style: TextStyle(
                          color: monthlyReportStatus!.contains('Error')
                              ? Colors.red
                              : Colors.green,
                          fontSize: 14,
                        ),
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

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightBlack.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryYellow.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: primaryYellow, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Reports are saved to your Downloads folder\n'
            '• Files are in Excel (.xlsx) format\n'
            '• Reports include attendance statistics and department breakdowns\n'
            '• Storage permission is required for downloads\n'
            '• Files can be opened with Excel or compatible apps\n'
            '• Check your Downloads folder in file manager',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to show success dialog with file location
  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: lightBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                  'Download Complete!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'File saved to Downloads folder',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: darkBlack,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    filePath,
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryYellow,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openFile(filePath);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryYellow,
                          foregroundColor: darkBlack,
                        ),
                        child: const Text(
                          'Open Downloads',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this method to open the file (optional)
  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);

      // Handle the result
      switch (result.type) {
        case ResultType.done:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File opened successfully'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
          break;

        case ResultType.fileNotFound:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File not found: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
          break;

        case ResultType.noAppToOpen:
          // Show dialog to suggest apps
          _showNoAppDialog(filePath);
          break;

        case ResultType.permissionDenied:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permission denied to open file'),
              backgroundColor: Colors.red,
            ),
          );
          break;

        case ResultType.error:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this method to show dialog when no app is available to open the file
  void _showNoAppDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: lightBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No App Found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No app is available to open Excel files. Please install an Excel viewer app from Google Play Store.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: darkBlack,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suggested Apps:',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Microsoft Excel\n• Google Sheets\n• WPS Office\n• OfficeSuite',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _copyFilePathToClipboard(filePath);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryYellow,
                          foregroundColor: darkBlack,
                        ),
                        child: const Text(
                          'Copy Path',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this method to copy file path to clipboard
  Future<void> _copyFilePathToClipboard(String filePath) async {
    try {
      await Clipboard.setData(ClipboardData(text: filePath));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File path copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy path: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Month/Year Picker Dialog
class _MonthYearPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const _MonthYearPicker({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  late int selectedYear;
  late int selectedMonth;

  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: lightBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Month & Year',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Year Selector
            Container(
              decoration: BoxDecoration(
                color: darkBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryYellow.withOpacity(0.3)),
              ),
              child: DropdownButton<int>(
                value: selectedYear,
                dropdownColor: lightBlack,
                underline: const SizedBox(),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: List.generate(10, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text('$year'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedYear = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // Month Selector
            Container(
              decoration: BoxDecoration(
                color: darkBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryYellow.withOpacity(0.3)),
              ),
              child: DropdownButton<int>(
                value: selectedMonth,
                dropdownColor: lightBlack,
                underline: const SizedBox(),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem<int>(
                    value: month,
                    child: Text(
                      DateFormat('MMMM').format(DateTime(2024, month)),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMonth = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedDate = DateTime(
                        selectedYear,
                        selectedMonth,
                      );
                      widget.onDateSelected(selectedDate);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryYellow,
                      foregroundColor: darkBlack,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
