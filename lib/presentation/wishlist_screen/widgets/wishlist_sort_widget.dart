import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Sort options for wishlist items
enum WishlistSortOption {
  dateAdded,
  titleAZ,
  titleZA,
  priceLowHigh,
  priceHighLow,
  author,
}

/// Sort widget for wishlist items
class WishlistSortWidget extends StatelessWidget {
  final WishlistSortOption currentSort;
  final ValueChanged<WishlistSortOption> onSortChanged;

  const WishlistSortWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSortBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: AppTheme.cardSurfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderSubtle, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'sort',
                color: AppTheme.textSecondary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                _getSortLabel(currentSort),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(width: 1.w),
              CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardSurfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Title
            Text(
              'Sort Wishlist',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            SizedBox(height: 3.h),

            // Sort options
            ...WishlistSortOption.values.map(
              (option) => _buildSortOption(
                context,
                option,
                _getSortLabel(option),
                _getSortIcon(option),
                currentSort == option,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    WishlistSortOption option,
    String label,
    String icon,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onSortChanged(option);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
          margin: EdgeInsets.only(bottom: 1.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.CafeAccent.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppTheme.CafeAccent, width: 1)
                : null,
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: isSelected
                    ? AppTheme.CafeAccent
                    : AppTheme.textSecondary,
                size: 24,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.CafeAccent
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected) ...[
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.CafeAccent,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getSortLabel(WishlistSortOption option) {
    switch (option) {
      case WishlistSortOption.dateAdded:
        return 'Date Added';
      case WishlistSortOption.titleAZ:
        return 'Title A-Z';
      case WishlistSortOption.titleZA:
        return 'Title Z-A';
      case WishlistSortOption.priceLowHigh:
        return 'Price: Low to High';
      case WishlistSortOption.priceHighLow:
        return 'Price: High to Low';
      case WishlistSortOption.author:
        return 'Author';
    }
  }

  String _getSortIcon(WishlistSortOption option) {
    switch (option) {
      case WishlistSortOption.dateAdded:
        return 'schedule';
      case WishlistSortOption.titleAZ:
        return 'sort_by_alpha';
      case WishlistSortOption.titleZA:
        return 'sort_by_alpha';
      case WishlistSortOption.priceLowHigh:
        return 'trending_up';
      case WishlistSortOption.priceHighLow:
        return 'trending_down';
      case WishlistSortOption.author:
        return 'person';
    }
  }
}
