import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class QuickActionsWidget extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback? onAddToWishlist;
  final VoidCallback? onShare;
  final VoidCallback? onViewSimilar;
  final VoidCallback? onDismiss;

  const QuickActionsWidget({
    super.key,
    required this.book,
    this.onAddToWishlist,
    this.onShare,
    this.onViewSimilar,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Book Info Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Book Cover
                Container(
                  width: 15.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: book['coverImage'] ?? '',
                      width: 15.w,
                      height: 20.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'] ?? 'Unknown Title',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          letterSpacing: 0.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        book['author'] ?? 'Unknown Author',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        book['price'] ?? '\$0.00',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                _buildActionButton(
                  icon: 'favorite_border',
                  label: 'Add to Wishlist',
                  onTap: () {
                    if (onAddToWishlist != null) onAddToWishlist!();
                    if (onDismiss != null) onDismiss!();
                  },
                ),
                SizedBox(height: 2.h),
                _buildActionButton(
                  icon: 'share',
                  label: 'Share Book',
                  onTap: () {
                    if (onShare != null) onShare!();
                    if (onDismiss != null) onDismiss!();
                  },
                ),
                SizedBox(height: 2.h),
                _buildActionButton(
                  icon: 'library_books',
                  label: 'View Similar Books',
                  onTap: () {
                    if (onViewSimilar != null) onViewSimilar!();
                    if (onDismiss != null) onDismiss!();
                  },
                ),
              ],
            ),
          ),

          // Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.primary,
                letterSpacing: 0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}