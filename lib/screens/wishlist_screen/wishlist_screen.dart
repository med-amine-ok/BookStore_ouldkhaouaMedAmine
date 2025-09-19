import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import 'widgets/empty_wishlist_widget.dart';
import 'widgets/wishlist_item_widget.dart';
import 'widgets/wishlist_search_widget.dart';
import 'widgets/wishlist_sort_widget.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
/// Wishlist Screen - Displays saved books collection with management features
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with TickerProviderStateMixin {
  // State variables
  bool _isEditMode = false;

  String _searchQuery = '';
  WishlistSortOption _currentSort = WishlistSortOption.dateAdded;
  List<int> _selectedItems = [];
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  List<Map<String, dynamic>> _wishlistBooks = [];
  List<Map<String, dynamic>> _AllBooks = [];
  bool _isLoading = true;
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadData();
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadData() async {
    try {
      
      if (!_authService.isAuthenticated || _authService.currentUser == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to view your wishlist'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final userId = _authService.currentUser!.id;
      final results = await Future.wait([
        _dataService.getWishlistBooks(userId),
        _dataService.getAlldBooks(),
      ]);

      setState(() {
        _wishlistBooks = results[0];
        _AllBooks = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
    _refreshController.dispose();
    super.dispose();
  }

  // Get filtered and sorted books
  List<Map<String, dynamic>> get _filteredBooks {
    List<Map<String, dynamic>> filtered = _wishlistBooks;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((book) {
        final title = (book["title"] as String).toLowerCase();
        final author = (book["author"] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || author.contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case WishlistSortOption.dateAdded:
        filtered.sort(
          (a, b) => (b["dateAdded"] as DateTime).compareTo(
            a["dateAdded"] as DateTime,
          ),
        );
        break;
      case WishlistSortOption.titleAZ:
        filtered.sort(
          (a, b) => (a["title"] as String).compareTo(b["title"] as String),
        );
        break;
      case WishlistSortOption.titleZA:
        filtered.sort(
          (a, b) => (b["title"] as String).compareTo(a["title"] as String),
        );
        break;
      case WishlistSortOption.priceLowHigh:
        filtered.sort((a, b) {
          final priceA = double.parse(
            (a["price"] as String).replaceAll('\$', ''),
          );
          final priceB = double.parse(
            (b["price"] as String).replaceAll('\$', ''),
          );
          return priceA.compareTo(priceB);
        });
        break;
      case WishlistSortOption.priceHighLow:
        filtered.sort((a, b) {
          final priceA = double.parse(
            (a["price"] as String).replaceAll('\$', ''),
          );
          final priceB = double.parse(
            (b["price"] as String).replaceAll('\$', ''),
          );
          return priceB.compareTo(priceA);
        });
        break;
      case WishlistSortOption.author:
        filtered.sort(
          (a, b) => (a["author"] as String).compareTo(b["author"] as String),
        );
        break;
    }

    return filtered;
  }

  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedItems.clear();
      }
    });
  }

  // Handle item selection in edit mode
  void _handleItemSelection(int bookId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(bookId);
      } else {
        _selectedItems.remove(bookId);
      }
    });
  }

  // Remove book from wishlist
  Future<void> _removeBook(int bookId) async {
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

    try {
      // Remove from database
      await _dataService.removeFromWishlist(userId, bookId);

      // Update local state
      setState(() {
        _wishlistBooks.removeWhere((book) => book["id"] == bookId);
        _selectedItems.remove(bookId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Book removed from wishlist'),
          backgroundColor: AppTheme.successGreen,
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppTheme.cardSurfaceLight,
            onPressed: () async {
              // Implement undo functionality
              try {
                await _dataService.addToWishlist(userId, bookId);
                await _loadData(); // Reload the wishlist
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Book restored to wishlist'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to restore book: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove book: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error removing book from wishlist: $e');
    }
  }

  // Remove selected books
  Future<void> _removeSelectedBooks() async {
    if (_selectedItems.isEmpty) return;

    if (!_authService.isAuthenticated || _authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to manage your wishlist'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Selected Books',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${_selectedItems.length} book${_selectedItems.length > 1 ? 's' : ''} from your wishlist?',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.cardSurfaceLight,
            ),
            child: Text(
              'Remove',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      final userId = _authService.currentUser!.id;

      try {
        // Remove all selected books from database
        for (final bookId in _selectedItems) {
          await _dataService.removeFromWishlist(userId, bookId);
        }

        setState(() {
          _wishlistBooks.removeWhere(
            (book) => _selectedItems.contains(book["id"]),
          );
          _selectedItems.clear();
          _isEditMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedItems.length} books removed from wishlist',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove books: $e'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('Error removing selected books: $e');
      }
    }
  }

  // Add selected books to cart
  void _addSelectedToCart() {
    if (_selectedItems.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedItems.length} books added to cart'),
        backgroundColor: AppTheme.successGreen,
      ),
    );

    setState(() {
      _selectedItems.clear();
      _isEditMode = false;
    });
  }

  // Handle pull to refresh
  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    _refreshController.forward();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    _refreshController.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wishlist updated'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Navigate to book detail
  void _navigateToBookDetail(Map<String, dynamic> book) {
    Navigator.pushNamed(context, '/book-detail-screen', arguments: book);
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _filteredBooks;

    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      appBar: _buildAppBar(),
      body: _wishlistBooks.isEmpty
          ? _buildEmptyState()
          : _buildWishlistContent(filteredBooks),
      bottomNavigationBar: CustomBottomBar.wishlist(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Wishlist',
      actions: [
        if (_wishlistBooks.isNotEmpty) ...[
          // Item count badge
          Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.CafeAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_filteredBooks.length}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.cardSurfaceLight,
              ),
            ),
          ),

          // Edit/Done button
          TextButton(
            onPressed: _toggleEditMode,
            child: Text(
              _isEditMode ? 'Done' : 'Edit',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.CafeAccent,
              ),
            ),
          ),
        ],
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyWishlistWidget(
      onBrowseBooks: () {
        Navigator.pushNamed(context, '/category-screen');
      },
    );
  }

  Widget _buildWishlistContent(List<Map<String, dynamic>> filteredBooks) {
    return Column(
      children: [
        // Search and sort controls
        if (_wishlistBooks.isNotEmpty) ...[
          WishlistSearchWidget(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),

          // Sort and filter row
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                WishlistSortWidget(
                  currentSort: _currentSort,
                  onSortChanged: (sort) {
                    setState(() {
                      _currentSort = sort;
                    });
                  },
                ),
                const Spacer(),
                if (_searchQuery.isNotEmpty) ...[
                  Text(
                    '${filteredBooks.length} result${filteredBooks.length != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        // Edit mode controls
        if (_isEditMode && _selectedItems.isNotEmpty) ...[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.CafeAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.CafeAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${_selectedItems.length} selected',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.CafeAccent,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _addSelectedToCart,
                  child: Text(
                    'Add to Cart',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.CafeAccent,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                TextButton(
                  onPressed: _removeSelectedBooks,
                  child: Text(
                    'Remove',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Wishlist items
        Expanded(
          child: filteredBooks.isEmpty
              ? _buildNoResultsState()
              : _buildBooksList(filteredBooks),
        ),
      ],
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.textMuted,
              size: 15.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'No books found',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _currentSort = WishlistSortOption.dateAdded;
                });
              },
              child: Text(
                'Clear Filters',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.CafeAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList(List<Map<String, dynamic>> filteredBooks) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.CafeAccent,
      backgroundColor: AppTheme.cardSurfaceLight,
      child: AnimatedBuilder(
        animation: _refreshAnimation,
        builder: (context, child) {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              final bookId = book["id"] as int;

              return WishlistItemWidget(
                book: book,
                isEditMode: _isEditMode,
                isSelected: _selectedItems.contains(bookId),
                onSelectionChanged: (isSelected) {
                  _handleItemSelection(bookId, isSelected);
                },
                onRemove: () => _removeBook(bookId),
                // onTap: () => _navigateToBookDetail(book),
              );
            },
          );
        },
      ),
    );
  }
}
