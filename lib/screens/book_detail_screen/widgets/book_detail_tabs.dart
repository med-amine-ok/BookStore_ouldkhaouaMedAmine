import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';


class BookDetailTabs extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailTabs({super.key, required this.book});

  @override
  State<BookDetailTabs> createState() => _BookDetailTabsState();
}

class _BookDetailTabsState extends State<BookDetailTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.CafeAccent,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.CafeAccent,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTheme.lightTheme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w400),
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
              Tab(text: 'Description'),
            ],
          ),
        ),

        // Tab Content
        SizedBox(
          height: 40.h, // Fixed height for tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _DetailsTab(book: widget.book),
              _ReviewsTab(book: widget.book),
              _DescriptionTab(book: widget.book),
            ],
          ),
        ),
      ],
    );
  }
}

/// Description tab with expandable text
class _DescriptionTab extends StatefulWidget {
  final Map<String, dynamic> book;

  const _DescriptionTab({required this.book});

  @override
  State<_DescriptionTab> createState() => _DescriptionTabState();
}

class _DescriptionTabState extends State<_DescriptionTab> {
  bool _isExpanded = false;
  static const int _maxLines = 6;

  @override
  Widget build(BuildContext context) {
    final description = widget.book['description'] as String;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            firstChild: Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.textPrimary,
              ),
              maxLines: _maxLines,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.textPrimary,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (description.split('\n').length > _maxLines ||
              description.length > 300) ...[
            SizedBox(height: 2.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                children: [
                  Text(
                    _isExpanded ? 'Read Less' : 'Read More',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.CafeAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: _isExpanded
                        ? 'keyboard_arrow_up'
                        : 'keyboard_arrow_down',
                    color: AppTheme.CafeAccent,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reviews tab with rating breakdown and individual reviews
class _ReviewsTab extends StatelessWidget {
  final Map<String, dynamic> book;

  const _ReviewsTab({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary
          _buildRatingSummary(),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${book['rating']}',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.CafeAccent,
                  ),
                ),
                _buildStarRating(book['rating'] as double),
                SizedBox(height: 1.h),
                Text(
                  '${book['reviewCount']} reviews',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Rating Breakdown
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                final percentage = _getRatingPercentage(stars);
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  child: Row(
                    children: [
                      Text(
                        '$stars',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: AppTheme.borderSubtle,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.CafeAccent,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${percentage.toInt()}%',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return CustomIconWidget(
            iconName: 'star',
            color: AppTheme.CafeAccent,
            size: 16,
          );
        } else if (index < rating) {
          return CustomIconWidget(
            iconName: 'star_half',
            color: AppTheme.CafeAccent,
            size: 16,
          );
        } else {
          return CustomIconWidget(
            iconName: 'star_border',
            color: AppTheme.textMuted,
            size: 16,
          );
        }
      }),
    );
  }

  double _getRatingPercentage(int stars) {
    // Mock rating distribution
    switch (stars) {
      case 5:
        return 65.0;
      case 4:
        return 20.0;
      case 3:
        return 10.0;
      case 2:
        return 3.0;
      case 1:
        return 2.0;
      default:
        return 0.0;
    }
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.CafeAccent.withValues(alpha: 0.1),
                child: Text(
                  (review['fullName'] as String).substring(0, 1).toUpperCase(),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.CafeAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['fullName'] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        _buildStarRating(review['rating'] as double),
                        SizedBox(width: 2.w),
                        Text(
                          review['date'] as String,
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            review['comment'] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Details tab with book specifications
class _DetailsTab extends StatelessWidget {
  final Map<String, dynamic> book;

  const _DetailsTab({required this.book});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          _buildDetailRow('Author', book['author'] ?? 'Unknown'),
          if (book['publication_date'] != null)
            _buildDetailRow(
              'Publication Date',
              book['publication_date'] as String,
            ),
          if (book['category'] != null)
            _buildDetailRow('Category', book['category'] as String),
          _buildDetailRow('Stock Quantity', '${book['stock_quantity'] ?? 0}'),
          _buildDetailRow('Average Rating', '${book['rating'] ?? 0.0}'),
          _buildDetailRow('Total Reviews', '${book['total_reviews'] ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
