import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Related books section with horizontal scroll
class RelatedBooksSection extends StatelessWidget {
  final Map<String, dynamic> currentBook;
  final List<Map<String, dynamic>> allBooks;

  const RelatedBooksSection({
    super.key,
    required this.currentBook,
    required this.allBooks,
  });

  @override
  Widget build(BuildContext context) {
    final relatedBooks = _getRelatedBooks();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'You might also like',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 35.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: relatedBooks.length,
              itemBuilder: (context, index) {
                final book = relatedBooks[index];
                return _RelatedBookCard(
                  book: book,
                  onTap: () => _navigateToBookDetail(context, book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRelatedBooks() {
    // Get related books from all books, excluding the current book
    return allBooks
        .where((book) => book['id'] != currentBook['id'])
        .take(5)
        .toList();
  }

  void _navigateToBookDetail(BuildContext context, Map<String, dynamic> book) {
    Navigator.pushNamed(context, '/book-detail-screen', arguments: book);
  }
}

/// Individual related book card
class _RelatedBookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onTap;

  const _RelatedBookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35.w,
      margin: EdgeInsets.only(right: 4.w),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'book_cover_${book['id']}',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowBase,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageWidget(
                      imageUrl: book['coverImage'] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Book Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book['title'] as String,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),

                  // Author
                  Text(
                    book['author'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Rating and Price
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: AppTheme.CafeAccent,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${book['rating']}',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),

                  // Price
                  Text(
                    '\$${book['price']}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.CafeAccent,
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
}
