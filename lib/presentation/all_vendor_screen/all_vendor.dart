import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/data_service.dart';

class AllVendorScreen extends StatefulWidget {
  const AllVendorScreen({super.key});

  @override
  State<AllVendorScreen> createState() => _AllVendorScreenState();
}

class _AllVendorScreenState extends State<AllVendorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  bool _isSearching = false;

  static const Duration _refreshDelay = Duration(seconds: 1);

  List<Map<String, dynamic>> _vendors = [];
  late List<Map<String, dynamic>> _filteredVendors;
  final DataService _dataService = DataService();
  bool _isLoading = true;

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([_dataService.getVendors()]);

      setState(() {
        _vendors = results[0];
        _filteredVendors = List<Map<String, dynamic>>.from(_vendors);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _filteredVendors = [];
      });
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error loading data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _filteredVendors = List<Map<String, dynamic>>.from(_vendors);
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'All Vendors',
      showBackButton: true,
      centerTitle: false,
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: _isSearching ? 'close' : 'search',
            color: AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Close search' : 'Search vendors',
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.CafeAccent,
      backgroundColor: AppTheme.cardSurfaceLight,
      child: Column(
        children: [
          if (_isSearching) _buildSearchBar(),
          _buildVendorStats(),
          Expanded(child: _buildVendorsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowBase,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'search',
            color: AppTheme.textSecondary,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
              autofocus: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.CafeAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.CafeAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Vendors', '${_filteredVendors.length}'),
          _buildStatItem('Total Books', _getTotalBooks()),
          _buildStatItem('Avg Rating', _getAverageRating()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.CafeAccent,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVendorsList() {
    if (_filteredVendors.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(4.w),
      itemCount: _filteredVendors.length,
      itemBuilder: (context, index) =>
          _buildVendorCard(_filteredVendors[index]),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowBase,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVendorHeader(vendor),
          SizedBox(height: 2.h),
          _buildVendorDescription(vendor),
          SizedBox(height: 2.h),
          _buildVendorDetails(vendor),
          SizedBox(height: 2.h),
          _buildViewBooksButton(vendor),
        ],
      ),
    );
  }

  Widget _buildVendorHeader(Map<String, dynamic> vendor) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            vendor['logo'],
            width: 15.w,
            height: 15.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: AppTheme.CafeAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'store',
                color: AppTheme.CafeAccent,
                size: 24,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor['full_name'],
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: Colors.amber,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    vendor['rating'].toString(),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  CustomIconWidget(
                    iconName: 'book',
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${vendor['totalBooks']}+',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVendorDescription(Map<String, dynamic> vendor) {
    return Text(
      vendor['description'],
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.textSecondary,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVendorDetails(Map<String, dynamic> vendor) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem('location', vendor['address'] ?? 'Unknown'),
        ),
        Expanded(
          child: _buildDetailItem(
            'calendar_today',
            'Est. ${vendor['established_year'] ?? 'N/A'}',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String iconName, String text) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.CafeAccent,
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildViewBooksButton(Map<String, dynamic> vendor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToVendorBooks(vendor),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.CafeAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'View Books',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search',
            color: AppTheme.textSecondary,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No vendors found',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search terms',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterVendors();
    });
  }

  void _filterVendors() {
    if (_searchQuery.isEmpty) {
      _filteredVendors = List<Map<String, dynamic>>.from(_vendors);
    } else {
      _filteredVendors = _vendors;
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _filteredVendors = List<Map<String, dynamic>>.from(_vendors);
      }
    });
  }

  void _navigateToVendorBooks(Map<String, dynamic> vendor) {
    Navigator.pushNamed(
      context,
      '/category-screen',
      arguments: {'vendor': vendor},
    );
  }

  String _getTotalBooks() {
    final total = _filteredVendors.fold<int>(
      0,
      (sum, vendor) => sum + vendor['totalBooks'] as int,
    );
    return total > 1000
        ? '${(total / 1000).toStringAsFixed(1)}k'
        : total.toString();
  }

  String _getAverageRating() {
    if (_filteredVendors.isEmpty) return '0.0';
    final average =
        _filteredVendors.fold<double>(
          0,
          (sum, vendor) => sum + vendor['rating'],
        ) /
        _filteredVendors.length;
    return average.toStringAsFixed(1);
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(_refreshDelay);
    if (mounted) {
      setState(() {
        _filteredVendors = List<Map<String, dynamic>>.from(_vendors);
      });
    }
  }
}
