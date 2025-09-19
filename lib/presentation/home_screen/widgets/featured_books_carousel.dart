import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class FeaturedBooksCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> books;
  final void Function(Map<String, dynamic>) onBookTap;
  final Future<void> Function(Map<String, dynamic>) onWishlistToggle;

  const FeaturedBooksCarousel({
    super.key,
    required this.books,
    required this.onBookTap,
    required this.onWishlistToggle,
  });

  @override
  State<FeaturedBooksCarousel> createState() => _FeaturedBooksCarouselState();
}

class _FeaturedBooksCarouselState extends State<FeaturedBooksCarousel> {
  static const int _infiniteScrollMultiplier = 10000;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.books.isNotEmpty
        ? widget.books.length * _infiniteScrollMultiplier ~/ 2
        : 0;
    _pageController = PageController(
      viewportFraction: 0.72,
      initialPage: initialPage,
    );

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  int _getRealIndex(int index) => index % widget.books.length;

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context),
        SizedBox(height: 2.h),
        SizedBox(
          height: 34.h,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              final realIndex = _getRealIndex(index);
              final book = widget.books[realIndex];
              final isActive = index == _currentPage;

              return AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isActive ? 1 : 0.92,
                curve: Curves.easeOut,
                child: BookCard(
                  book: book,
                  onTap: () => widget.onBookTap(book),
                  onWishlistToggle: () => widget.onWishlistToggle(book),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 2.h),
        _dotIndicator(),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Featured Books',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/category-screen'),
            child: Text(
              'View All',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.CafeAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotIndicator() {
    final realPage = _getRealIndex(_currentPage);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.books.length, (index) {
        final isActive = index == realPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: isActive ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.CafeAccent
                : AppTheme.textMuted.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isInWishlist = (book['isInWishlist'] as bool?) ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onWishlistToggle,
      child: Hero(
        tag: 'book_${book['id']}',
        child: Card(
          elevation: 4,
          shadowColor: AppTheme.shadowBase.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Expanded(flex: 3, child: BookCover(imageUrl: book['coverImage'])),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BookInfo(
                        title: book['title'] ?? 'Unknown Title',
                        author: book['author'] ?? 'Unknown Author',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${book['price']?.toString() ?? 'Price not available'}',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.CafeAccent,
                            ),
                          ),
                          GestureDetector(
                            onTap: onWishlistToggle,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: CustomIconWidget(
                                key: ValueKey(
                                  'wishlist_${book['id']}_$isInWishlist',
                                ),
                                iconName: isInWishlist
                                    ? 'favorite'
                                    : 'favorite_border',
                                color: isInWishlist
                                    ? AppTheme.CafeAccent
                                    : AppTheme.textMuted,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  final String imageUrl;

  const BookCover({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImageWidget(imageUrl: imageUrl, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.15), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookInfo extends StatelessWidget {
  final String title;
  final String author;

  const BookInfo({super.key, required this.title, required this.author});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          author,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
