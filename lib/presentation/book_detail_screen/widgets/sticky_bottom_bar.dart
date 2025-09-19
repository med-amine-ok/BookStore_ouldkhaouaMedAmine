import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Sticky bottom bar with price and purchase button
/// Appears when scrolling past initial view
class StickyBottomBar extends StatelessWidget {
  final Map<String, dynamic> book;
  final bool isVisible;

  const StickyBottomBar({
    super.key,
    required this.book,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(0, isVisible ? 0 : 20.h, 0),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.cardSurfaceLight,
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowBase,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price Section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (book['originalPrice'] != null &&
                        book['originalPrice'] != book['price']) ...[
                      Text(
                        '\$${book['originalPrice']}',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.textMuted,
                            ),
                      ),
                    ],
                    Text(
                      '\$${book['price']}',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.CafeAccent,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),

              // Add to Cart Button
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () => _addToCart(context),
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
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Add to Cart',
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cardSurfaceLight,
                            ),
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

  void _addToCart(BuildContext context) {
    // Add to cart functionality
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
                '${book['title']} added to cart',
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
      ),
    );
  }
}
