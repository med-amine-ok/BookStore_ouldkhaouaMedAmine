import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/featured_books_carousel.dart';
import './widgets/search_overlay.dart';
import './widgets/vendor_showcase.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearchOverlayVisible = false;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _featuredBooks = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _vendors = [];

  static const Duration _snackBarDuration = Duration(seconds: 2);

  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  static const List<String> _navigationRoutes = [
    '/home-screen',
    '/category-screen',
    '/wishlist-screen',
    '/profile-screen',
    '/all-vendor-screen',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!AuthService().isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.signIn,
          (route) => false,
        );
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _dataService.getFeaturedBooks(),
        _dataService.getCategories(),
        _dataService.getVendors(),
      ]);

      setState(() {
        _featuredBooks = results[0];
        _categories = results[1];
        _vendors = results[2];
        _isLoading = false;
      });

      // Update wishlist status for featured books if user is authenticated
      if (_authService.isAuthenticated && _authService.currentUser != null) {
        final userId = _authService.currentUser!.id;
        final featuredBooksWithWishlist = await _dataService
            .updateBooksWishlistStatus(userId, _featuredBooks);
        setState(() {
          _featuredBooks = featuredBooksWithWishlist;
        });
      }

      // Debug prints
      debugPrint('Featured books: ${_featuredBooks.length}');
      debugPrint('Categories: ${_categories.length}');
      debugPrint('Vendors: ${_vendors.length}');
    } catch (e) {
      setState(() => _isLoading = false);
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'BookStore',
      showBackButton: false,
      centerTitle: false,
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'search',
            color: AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: _toggleSearchOverlay,
          tooltip: 'Search books',
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        _buildMainContent(),
        if (_isSearchOverlayVisible) _buildSearchOverlay(),
      ],
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.CafeAccent,
      backgroundColor: AppTheme.cardSurfaceLight,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildWelcomeSection(),
          _buildFeaturedBooksSection(),
          SliverToBoxAdapter(child: SizedBox(height: 4.h)),
          _buildVendorShowcaseSection(),
          _buildCategoriesSection(),
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Discover your next favorite book',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBooksSection() {
    if (_featuredBooks.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: Text("No featured books")),
      );
    }

    return SliverToBoxAdapter(
      child: FeaturedBooksCarousel(
        books: _featuredBooks,
        onBookTap: _handleBookTap,
        onWishlistToggle: _handleWishlistToggle,
      ),
    );
  }

  Widget _buildVendorShowcaseSection() {
    if (_vendors.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Text("No vendors")));
    }

    return SliverToBoxAdapter(
      child: VendorShowcase(vendors: _vendors, onVendorTap: _handleVendorTap),
    );
  }

  Widget _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse Categories',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            _categories.isEmpty
                ? const Center(child: Text("No categories"))
                : _buildCategoriesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 3.2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) => _buildCategoryCard(_categories[index]),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _navigateToCategory(category['name']),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
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
            _buildCategoryIcon(category['iconName']),
            SizedBox(width: 2.w),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    category['name'],
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    category['book_count'].toString(),
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String iconName) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.CafeAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.CafeAccent,
        size: 20,
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return SearchOverlay(
      onSearch: _handleSearch,
      onClose: _toggleSearchOverlay,
    );
  }

  Widget _buildBottomNavigationBar() {
    return CustomBottomBar.home(onTap: _handleBottomNavigationTap);
  }

  void _handleBookTap(Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          book['coverImage'],
                          width: 35.w,
                          height: 40.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['title'],
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 3,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              "by ${book['author']}",
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              '\$${book['price']?.toString() ?? 'Price not available'}',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.CafeAccent,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                Text(
                                  "⭐ ${book['rating']?.toString() ?? 'N/A'}",
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  book['category'],
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "About this book",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "This is a fascinating book that explores deep ideas and engaging storytelling. "
                    "It has captivated readers worldwide with its unique approach and thoughtful narrative.",
                    style: GoogleFonts.inter(
                      fontSize: 17.sp,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 8,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.CafeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                          icon: Icon(
                            book['isInWishlist']
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          label: Text(
                            book['isInWishlist']
                                ? "Remove from Wishlist"
                                : "Add to Wishlist",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _handleWishlistToggle(book);
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.CafeAccent, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/book-detail-screen',
                          arguments: book,
                        );
                      },
                      child: Text(
                        "View Full Details",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.CafeAccent,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleWishlistToggle(Map<String, dynamic> book) async {
    if (!_authService.isAuthenticated || _authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to manage your wishlist'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = _authService.currentUser!.id;
    final bookId = book['id'] as int;
    final wasInWishlist = book['isInWishlist'] as bool;

    try {
      if (wasInWishlist) {
        // Remove from wishlist
        await _dataService.removeFromWishlist(userId, bookId);
        setState(() {
          final index = _featuredBooks.indexWhere((b) => b['id'] == bookId);
          if (index != -1) {
            _featuredBooks[index]['isInWishlist'] = false;
          }
        });
      } else {
        // Add to wishlist
        await _dataService.addToWishlist(userId, bookId);
        setState(() {
          final index = _featuredBooks.indexWhere((b) => b['id'] == bookId);
          if (index != -1) {
            _featuredBooks[index]['isInWishlist'] = true;
          }
        });
      }

      _showWishlistSnackBar(wasInWishlist);
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update wishlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWishlistSnackBar(bool wasInWishlist) {
    final message = wasInWishlist
        ? 'Removed from wishlist'
        : 'Added to wishlist';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppTheme.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: _snackBarDuration,
      ),
    );
  }

  void _handleVendorTap(Map<String, dynamic> vendor) {
    Navigator.pushNamed(
      context,
      '/all-vendor-screen',
      arguments: {'vendor': vendor},
    );
  }

  void _handleSearch(String query) {
    Navigator.pushNamed(
      context,
      '/category-screen',
      arguments: {'searchQuery': query},
    );
  }

  void _navigateToCategory(String category) {
    Navigator.pushNamed(
      context,
      '/category-screen',
      arguments: {'category': category},
    );
  }

  void _toggleSearchOverlay() {
    setState(() {
      _isSearchOverlayVisible = !_isSearchOverlayVisible;
    });
  }

  void _handleBottomNavigationTap(int index) {
    if (index != 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        _navigationRoutes[index],
        (route) => false,
      );
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
    if (mounted) setState(() {});
  }
}

class BookCategory {
  final String title;
  final String iconName;
  final int bookCount;

  const BookCategory(this.title, this.iconName, this.bookCount);
}