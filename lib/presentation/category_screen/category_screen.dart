import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/book_card_widget.dart';
import './widgets/category_chip_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/quick_actions_widget.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();

  int _selectedCategoryIndex = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Map<String, dynamic> _currentFilters = {};

  static const Duration _loadingDelay = Duration(milliseconds: 300);
  static const Duration _refreshDelay = Duration(seconds: 1);
  static const Duration _loadMoreDelay = Duration(seconds: 1);
  static const Duration _snackBarDuration = Duration(seconds: 2);
  static const double _scrollThreshold = 200.0;

  List<Map<String, dynamic>> _AllBooks = [];
  List<Map<String, dynamic>> _categories = [];
  late List<Map<String, dynamic>> _filteredBooks;

  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();
  bool _isLoadingg = true;

  @override
  void initState() {
    super.initState();
    _filteredBooks = List<Map<String, dynamic>>.from(_AllBooks);
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _dataService.getAlldBooks(),
        _dataService.getCategories(),
        _dataService.getVendors(),
      ]);

      List<Map<String, dynamic>> allBooks = results[0];
      _categories = results[1];

      // Update wishlist status for books if user is authenticated
      if (_authService.isAuthenticated && _authService.currentUser != null) {
        final userId = _authService.currentUser!.id;
        allBooks = await _dataService.updateBooksWishlistStatus(
          userId,
          allBooks,
        );
      }

      setState(() {
        _AllBooks = allBooks;
        _filteredBooks = List<Map<String, dynamic>>.from(_AllBooks);
        _isLoadingg = false;
      });

      // Apply current category filter after loading data
      _filterBooks();
    } catch (e) {
      setState(() => _isLoadingg = false);
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
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar.category(onFilterTap: _showFilterBottomSheet);
  }

  Widget _buildBody() {
    if (_isLoadingg) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(children: [_buildCategoryChips(), _buildBooksSection()]);
  }

  Widget _buildCategoryChips() {
    // Show loading if categories are still being loaded
    if (_isLoadingg) {
      return Container(
        height: 8.h,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Center(
          child: SizedBox(
            height: 2.h,
            width: 2.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _categories.length + 1, // +1 for "All"
        itemBuilder: _buildCategoryChip,
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, int index) {
    if (index == 0) {
      // "All" category
      return CategoryChipWidget(
        label: 'All',
        isSelected: _selectedCategoryIndex == 0,
        onTap: () => _onCategorySelected(0),
      );
    } else {
      final categoryIndex = index - 1;
      return CategoryChipWidget(
        label: _categories[categoryIndex]['name'] ?? 'Unknown',
        isSelected: _selectedCategoryIndex == index,
        onTap: () => _onCategorySelected(index),
      );
    }
  }

  Widget _buildBooksSection() {
    return Expanded(
      child: _isLoading
          ? _buildLoadingGrid()
          : _filteredBooks.isEmpty
          ? _buildEmptyState()
          : _buildBooksGrid(),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: 'No Books Found',
      subtitle:
          'Try adjusting your filters or browse other categories to discover amazing books.',
      buttonText: 'Browse Other Categories',
      iconName: 'search_off',
      onButtonPressed: _resetFilters,
    );
  }

  Widget _buildBooksGrid() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 4.w,
          childAspectRatio: 0.65,
        ),
        itemCount: _filteredBooks.length + (_isLoadingMore ? 2 : 0),
        itemBuilder: _buildGridItem,
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, int index) {
    if (index >= _filteredBooks.length) {
      return _buildLoadingCard();
    }

    final book = _filteredBooks[index];
    return BookCardWidget(
      book: book,
      onTap: () => _navigateToBookDetail(book),
      onWishlistTap: () => _toggleWishlist(book),
      onLongPress: () => _showQuickActions(book),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(
              alpha: 0.1,
            ),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildLoadingCover(), _buildLoadingDetails()],
      ),
    );
  }

  Widget _buildLoadingCover() {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDetails() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLoadingBar(80.w, 2.h),
            SizedBox(height: 1.h),
            _buildLoadingBar(60.w, 1.5.h),
            const Spacer(),
            _buildLoadingBar(40.w, 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBar(double width, double height) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return CustomBottomBar.category();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _scrollThreshold) {
      _loadMoreBooks();
    }
  }

  void _loadMoreBooks() {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    Future.delayed(_loadMoreDelay, () {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    });
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _isLoading = true;
    });

    _filterBooks();

    Future.delayed(_loadingDelay, () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _filterBooks() {
    List<Map<String, dynamic>> filtered = List<Map<String, dynamic>>.from(
      _AllBooks,
    );

    filtered = _applyCategoryFilter(filtered);
    filtered = _applyFilters(filtered);

    setState(() => _filteredBooks = filtered);
  }

  List<Map<String, dynamic>> _applyCategoryFilter(
    List<Map<String, dynamic>> books,
  ) {
    if (_selectedCategoryIndex == 0) return books;

    final selectedCategory = _categories[_selectedCategoryIndex - 1];
    return books
        .where((book) => book['category'] == selectedCategory['name'])
        .toList();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> books) {
    if (_currentFilters.isEmpty) return books;

    books = _applyPriceRangeFilter(books);
    books = _applyRatingFilter(books);
    books = _applyAvailabilityFilter(books);
    books = _applySorting(books);

    return books;
  }

  List<Map<String, dynamic>> _applyPriceRangeFilter(
    List<Map<String, dynamic>> books,
  ) {
    final priceRange = _currentFilters['priceRange'] as RangeValues?;
    if (priceRange == null) return books;

    return books.where((book) {
      final price = _parsePrice(book['price']);
      return price >= priceRange.start && price <= priceRange.end;
    }).toList();
  }

  List<Map<String, dynamic>> _applyRatingFilter(
    List<Map<String, dynamic>> books,
  ) {
    final minRating = _currentFilters['minRating'] as double?;
    if (minRating == null || minRating <= 0) return books;

    return books.where((book) => (book['rating'] ?? 0) >= minRating).toList();
  }

  List<Map<String, dynamic>> _applyAvailabilityFilter(
    List<Map<String, dynamic>> books,
  ) {
    final availableOnly = _currentFilters['availableOnly'] as bool?;
    if (availableOnly != true) return books;

    return books.where((book) => book['isAvailable'] == true).toList();
  }

  List<Map<String, dynamic>> _applySorting(List<Map<String, dynamic>> books) {
    final sortBy = _currentFilters['sortBy'] as String?;
    if (sortBy == null) return books;

    switch (sortBy) {
      case 'Price: Low to High':
        return _sortByPrice(books, ascending: true);
      case 'Price: High to Low':
        return _sortByPrice(books, ascending: false);
      case 'Rating':
        return _sortByRating(books);
      case 'A-Z':
        return _sortByTitle(books, ascending: true);
      case 'Z-A':
        return _sortByTitle(books, ascending: false);
      case 'Newest':
        return _sortByDate(books);
      default:
        return books;
    }
  }

  List<Map<String, dynamic>> _sortByPrice(
    List<Map<String, dynamic>> books, {
    required bool ascending,
  }) {
    books.sort((a, b) {
      final priceA = _parsePrice(a['price']);
      final priceB = _parsePrice(b['price']);
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    return books;
  }

  List<Map<String, dynamic>> _sortByRating(List<Map<String, dynamic>> books) {
    books.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    return books;
  }

  List<Map<String, dynamic>> _sortByTitle(
    List<Map<String, dynamic>> books, {
    required bool ascending,
  }) {
    books.sort((a, b) {
      final titleA = a['title'] ?? '';
      final titleB = b['title'] ?? '';
      return ascending ? titleA.compareTo(titleB) : titleB.compareTo(titleA);
    });
    return books;
  }

  List<Map<String, dynamic>> _sortByDate(List<Map<String, dynamic>> books) {
    books.sort((a, b) {
      final dateA = DateTime.parse(a['publishedDate'] ?? '1900-01-01');
      final dateB = DateTime.parse(b['publishedDate'] ?? '1900-01-01');
      return dateB.compareTo(dateA);
    });
    return books;
  }

  double _parsePrice(dynamic price) {
    if (price is num) return price.toDouble();
    if (price is String)
      return double.tryParse(price.replaceAll('\$', '')) ?? 0;
    return 0;
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);

    await Future.delayed(_refreshDelay);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _filteredBooks = List<Map<String, dynamic>>.from(_AllBooks);
      });
      _filterBooks();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: 80.h,
        child: FilterBottomSheetWidget(
          onApplyFilters: _applyFiltersFromBottomSheet,
        ),
      ),
    );
  }

  void _applyFiltersFromBottomSheet(Map<String, dynamic> filters) {
    setState(() => _currentFilters = filters);
    _filterBooks();
  }

  void _showQuickActions(Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsWidget(
        book: book,
        onAddToWishlist: () => _handleQuickWishlist(book),
        onShare: () => _handleQuickShare(book),
        onViewSimilar: () => _handleViewSimilar(),
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  void _handleQuickWishlist(Map<String, dynamic> book) {
    _showSnackBar('${book['title']} added to wishlist');
  }

  void _handleQuickShare(Map<String, dynamic> book) {
    _showSnackBar('Sharing ${book['title']}');
  }

  void _handleViewSimilar() {
    Navigator.pushNamed(context, '/category-screen');
  }

  void _navigateToBookDetail(Map<String, dynamic> book) {
    Navigator.pushNamed(context, '/book-detail-screen', arguments: book);
  }

  Future<void> _toggleWishlist(Map<String, dynamic> book) async {
    if (!_authService.isAuthenticated || _authService.currentUser == null) {
      _showSnackBar('Please sign in to add to wishlist');
      return;
    }

    final userId = _authService.currentUser!.id;
    final bookId = book['id'] as int;
    final wasInWishlist = book['isInWishlist'] ?? false;

    try {
      if (wasInWishlist) {
        await _dataService.removeFromWishlist(userId, bookId);
        setState(() {
          book['isInWishlist'] = false;
        });
        _showSnackBar('${book['title']} removed from wishlist');
      } else {
        await _dataService.addToWishlist(userId, bookId);
        setState(() {
          book['isInWishlist'] = true;
        });
        _showSnackBar('${book['title']} added to wishlist');
      }
    } catch (e) {
      _showSnackBar('Failed to update wishlist: $e');
      debugPrint('Error toggling wishlist: $e');
    }
  }

  Future<void> _resetFilters() async {
    setState(() {
      _selectedCategoryIndex = 0;
      _currentFilters.clear();
      _isLoadingg = true;
    });

    // Scroll to top to show categories
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Reload data
    await _loadData();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: _snackBarDuration),
    );
  }

  int _getCrossAxisCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 ? 3 : 2;
  }
}
