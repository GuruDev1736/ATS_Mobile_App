import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ShowOffice.dart';

class OfficeDetailsScreen extends StatefulWidget {
  final Office office;

  const OfficeDetailsScreen({super.key, required this.office});

  @override
  State<OfficeDetailsScreen> createState() => _OfficeDetailsScreenState();
}

class _OfficeDetailsScreenState extends State<OfficeDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Color theme matching AttendanceDashboard
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);

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

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlack,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickStatsSection(),
                      const SizedBox(height: 24),
                      _buildDetailsSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: darkBlack,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: lightBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryYellow.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: lightBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryYellow.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.share, color: primaryYellow),
            onPressed: () {
              // Share functionality
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: lightBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryYellow.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.more_vert, color: primaryYellow),
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkBlack, lightBlack, darkBlack],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryYellow, darkYellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primaryYellow.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      color: Colors.black,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.office.officeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryYellow.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Office ID: ${widget.office.id}',
                      style: TextStyle(
                        color: primaryYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                icon: Icons.people,
                label: 'Total Employees',
                value: '${widget.office.totalMembers}',
                color: primaryYellow,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickStatCard(
                icon: Icons.location_on,
                label: 'Status',
                value: 'Active',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                icon: Icons.access_time,
                label: 'Working Hours',
                value: '9 AM - 6 PM',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickStatCard(
                icon: Icons.business_center,
                label: 'Departments',
                value: '8',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Office Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          icon: Icons.location_city,
          title: 'Office Address',
          subtitle: widget.office.address,
          trailing: IconButton(
            icon: Icon(Icons.copy, color: primaryYellow),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.office.address));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Address copied to clipboard'),
                  backgroundColor: primaryYellow,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.gps_fixed,
          title: 'GPS Coordinates',
          subtitle: '${widget.office.latitude}, ${widget.office.longitude}',
          trailing: IconButton(
            icon: Icon(Icons.open_in_new, color: primaryYellow),
            onPressed: () {
              // Open in maps
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.groups,
          title: 'Team Information',
          subtitle: '${widget.office.totalMembers} active employees',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.schedule,
          title: 'Operating Hours',
          subtitle: 'Monday - Friday: 9:00 AM - 6:00 PM',
          trailing: Icon(Icons.schedule, color: primaryYellow),
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.phone,
          title: 'Contact Information',
          subtitle: '+1 (555) 123-4567',
          trailing: IconButton(
            icon: Icon(Icons.call, color: primaryYellow),
            onPressed: () {
              // Call functionality
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryYellow, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.map,
                label: 'View on Map',
                isPrimary: true,
                onPressed: () {
                  // Open map functionality
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.directions,
                label: 'Get Directions',
                isPrimary: false,
                onPressed: () {
                  // Get directions functionality
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.people,
                label: 'View Employees',
                isPrimary: false,
                onPressed: () {
                  // View employees functionality
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit,
                label: 'Edit Office',
                isPrimary: false,
                onPressed: () {
                  // Edit office functionality
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [primaryYellow, darkYellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : lightBlack,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? primaryYellow.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.black : Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionTile(
              icon: Icons.edit,
              title: 'Edit Office Details',
              onTap: () {
                Navigator.pop(context);
                // Edit functionality
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_outline,
              title: 'Delete Office',
              onTap: () {
                Navigator.pop(context);
                // Delete functionality
              },
            ),
            _buildOptionTile(
              icon: Icons.settings,
              title: 'Office Settings',
              onTap: () {
                Navigator.pop(context);
                // Settings functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: darkBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryYellow),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
