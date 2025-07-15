import 'package:ata_mobile/Screens/Dashboard/Office/OfficeDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowOffice extends StatefulWidget {
  const ShowOffice({super.key});

  @override
  State<ShowOffice> createState() => _ShowOfficeState();
}

class _ShowOfficeState extends State<ShowOffice> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Color theme matching AttendanceDashboard
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFF8F00);
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkBlack = Color(0xFF1A1A1A);
  static const Color lightBlack = Color(0xFF2D2D2D);

  // UI state - removed _isGridView
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Sample office data - replace with your API data
  List<Office> _offices = [
    Office(
      id: 1,
      latitude: '40.7128',
      longitude: '-74.0060',
      address: '123 Broadway, New York, NY 10001',
      officeName: 'New York Headquarters',
      totalMembers: 45,
    ),
    Office(
      id: 2,
      latitude: '34.0522',
      longitude: '-118.2437',
      address: '456 Sunset Blvd, Los Angeles, CA 90028',
      officeName: 'Los Angeles Branch',
      totalMembers: 32,
    ),
    Office(
      id: 3,
      latitude: '41.8781',
      longitude: '-87.6298',
      address: '789 Michigan Ave, Chicago, IL 60611',
      officeName: 'Chicago Office',
      totalMembers: 28,
    ),
    Office(
      id: 4,
      latitude: '47.6062',
      longitude: '-122.3321',
      address: '321 Pine St, Seattle, WA 98101',
      officeName: 'Seattle Tech Hub',
      totalMembers: 67,
    ),
    Office(
      id: 5,
      latitude: '29.7604',
      longitude: '-95.3698',
      address: '555 Main St, Houston, TX 77002',
      officeName: 'Houston Operations',
      totalMembers: 38,
    ),
  ];

  List<Office> _filteredOffices = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _filteredOffices = _offices;
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
    _searchController.dispose();
    super.dispose();
  }

  void _filterOffices(String query) {
    setState(() {
      _searchQuery = query;
      _filteredOffices = _offices
          .where(
            (office) =>
                office.officeName.toLowerCase().contains(query.toLowerCase()) ||
                office.address.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
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
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildOfficeList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: darkBlack,
      foregroundColor: Colors.white,
      elevation: 0,
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
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
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
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Office Locations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage office locations',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        // Removed layout toggle button, kept only refresh button
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: lightBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryYellow.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.refresh, color: primaryYellow),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  _isLoading = false;
                });
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterOffices,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search offices...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: primaryYellow),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.6)),
                  onPressed: () {
                    _searchController.clear();
                    _filterOffices('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    int totalMembers = _filteredOffices.fold(
      0,
      (sum, office) => sum + office.totalMembers,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.business,
            label: 'Total Offices',
            value: _filteredOffices.length.toString(),
            color: primaryYellow,
          ),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            icon: Icons.people,
            label: 'Total Members',
            value: totalMembers.toString(),
            color: Colors.white,
          ),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            icon: Icons.location_on,
            label: 'Locations',
            value: _filteredOffices.length.toString(),
            color: darkYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildOfficeList() {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: CircularProgressIndicator(color: primaryYellow),
          ),
        ),
      );
    }

    if (_filteredOffices.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.white.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No offices found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search terms',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Always show list view now
    return _buildListView();
  }

  Widget _buildListView() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final office = _filteredOffices[index];
          return _buildOfficeListCard(office);
        }, childCount: _filteredOffices.length),
      ),
    );
  }

  Widget _buildOfficeListCard(Office office) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: lightBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryYellow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfficeDetailsScreen(office: office),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: primaryYellow.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        office.officeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              office.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Members container - flexible to take available space
                          Flexible(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryYellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: primaryYellow.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 12,
                                    color: primaryYellow,
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      '${office.totalMembers} members',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: primaryYellow,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // View Map container - flexible to take remaining space
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      'Map',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    onPressed: () => _showOfficeOptions(office),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOfficeOptions(Office office) {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack, // Changed from transparent
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: lightBlack,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: primaryYellow.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              icon: Icons.info_outline,
              title: 'View Details',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfficeDetailsScreen(office: office),
                  ),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.map_outlined,
              title: 'View on Map',
              onTap: () {
                Navigator.pop(context);
                // Open map functionality
              },
            ),
            _buildOptionTile(
              icon: Icons.directions_outlined,
              title: 'Get Directions',
              onTap: () {
                Navigator.pop(context);
                // Get directions functionality
              },
            ),
            _buildOptionTile(
              icon: Icons.share_outlined,
              title: 'Share Location',
              onTap: () {
                Navigator.pop(context);
                // Share location functionality
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailCard({
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
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryYellow, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [primaryYellow, darkYellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : lightBlack,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? null
            : Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.black : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

// Office model class
class Office {
  final int id;
  final String latitude;
  final String longitude;
  final String address;
  final String officeName;
  final int totalMembers;

  Office({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.officeName,
    required this.totalMembers,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      officeName: json['officeName'],
      totalMembers: json['totalMembers'],
    );
  }
}
