import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';


class EmptyWishlistWidget extends StatelessWidget {
  final VoidCallback? onBrowseBooks;

  const EmptyWishlistWidget({super.key, this.onBrowseBooks});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heart illustration
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppTheme.CafeAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'favorite_border',
                  color: AppTheme.CafeAccent,
                  size: 15.w,
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'Your Wishlist is Empty',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'Start adding books you love\nand create your perfect reading list',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 6.h),

            // Browse books button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    onBrowseBooks ??
                    () {
                      Navigator.pushNamed(context, '/category-screen');
                    },
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
                      iconName: 'explore',
                      color: AppTheme.cardSurfaceLight,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Browse Books',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Secondary action
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home-screen');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 6.w),
              ),
              child: Text(
                'Go to Home',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 1.w,
          height: 1.w,
          margin: EdgeInsets.only(top: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.CafeAccent,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
