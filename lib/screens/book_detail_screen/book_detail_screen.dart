import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'widgets/book_cover_hero.dart';
import 'widgets/book_detail_tabs.dart';
import 'widgets/book_info_section.dart';
import 'widgets/related_books_section.dart';
import 'widgets/sticky_bottom_bar.dart';
import '../../services/data_service.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late ScrollController _scrollController;
  bool _showStickyBar = false;
  Map<String, dynamic>? _book;
  bool _isLoading = true;
  bool _hasError = false;

  List<Map<String, dynamic>> _AllBooks = [];
  final DataService _dataService = DataService();
  bool _isLoadingg = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadData().then((_) {
      _loadBookData();
    });
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([_dataService.getAlldBooks()]);

      setState(() {
        _AllBooks = results[0];
        _isLoadingg = false;
      });
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 30.h;
    if (shouldShow != _showStickyBar) {
      setState(() {
        _showStickyBar = shouldShow;
      });
    }
  }

  void _loadBookData() {
    try {
      // Get book data from arguments or use default
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      setState(() {
        _book = args ?? _AllBooks[0];
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadBookData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError || _book == null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          BookCoverHero(book: _book!, scrollController: _scrollController),
          SliverToBoxAdapter(child: BookInfoSection(book: _book!)),
          SliverToBoxAdapter(child: _buildMainAddToCartButton()),
          SliverToBoxAdapter(child: BookDetailTabs(book: _book!)),
          SliverToBoxAdapter(
            child: RelatedBooksSection(
              currentBook: _book!,
              allBooks: _AllBooks,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        ],
      ),
      bottomNavigationBar: StickyBottomBar(
        book: _book!,
        isVisible: _showStickyBar,
      ),
    );
  }

  Widget _buildMainAddToCartButton() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: ElevatedButton(
        onPressed: () => _addToCart(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.CafeAccent,
          foregroundColor: AppTheme.cardSurfaceLight,
          padding: EdgeInsets.symmetric(vertical: 3.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'shopping_cart',
              color: AppTheme.cardSurfaceLight,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Text(
              'Add to Cart - \$${_book!['price']}',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.cardSurfaceLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 40.h,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryBackgroundLight,
            elevation: 0,
            leading: IconButton(
              icon: CustomIconWidget(
                iconName: 'arrow_back_ios',
                color: AppTheme.textPrimary,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primaryBackgroundLight,
                child: Center(
                  child: Container(
                    width: 50.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.CafeAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildSkeletonContent()),
        ],
      ),
    );
  }

  Widget _buildSkeletonContent() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title skeleton
          Container(
            width: 80.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: AppTheme.borderSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 1.h),

          // Author skeleton
          Container(
            width: 60.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: AppTheme.borderSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 2.h),

          // Rating skeleton
          Row(
            children: List.generate(
              5,
              (index) => Container(
                width: 4.w,
                height: 4.w,
                margin: EdgeInsets.only(right: 1.w),
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Price skeleton
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.borderSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Details',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.errorRed,
                size: 64,
              ),
              SizedBox(height: 3.h),
              Text(
                'Unable to load book details',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Please check your internet connection and try again.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: _retryLoading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.CafeAccent,
                  foregroundColor: AppTheme.cardSurfaceLight,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'refresh',
                      color: AppTheme.cardSurfaceLight,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Try Again',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cardSurfaceLight,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successGreen,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                '${_book!['title']} added to cart',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.cardSurfaceLight,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.textPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppTheme.CafeAccent,
          onPressed: () {
            // Navigate to cart screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cart functionality coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}
