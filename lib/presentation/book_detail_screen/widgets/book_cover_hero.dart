import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Hero animated book cover widget for book detail screen
/// Provides smooth transition from previous screen with parallax effect
class BookCoverHero extends StatelessWidget {
  final Map<String, dynamic> book;
  final ScrollController scrollController;

  const BookCoverHero({
    super.key,
    required this.book,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 40.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back_ios',
          color: AppTheme.textPrimary,
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'share',
            color: AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: () => _shareBook(context),
        ),
        SizedBox(width: 2.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBackgroundLight,
                AppTheme.primaryBackgroundLight.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'book_cover_${book['id']}',
              child: Container(
                width: 50.w,
                height: 30.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowBase,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomImageWidget(
                    imageUrl: book['coverImage'] as String,
                    width: 50.w,
                    height: 30.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _shareBook(BuildContext context) {
    // Share book functionality
    final bookTitle = book['title'] as String;
    final bookAuthor = book['author'] as String;
    final shareText = 'Check out "$bookTitle" by $bookAuthor on BookStore!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: $shareText'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
