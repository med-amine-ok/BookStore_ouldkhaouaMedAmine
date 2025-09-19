import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class VendorShowcase extends StatelessWidget {
  final List<Map<String, dynamic>> vendors;
  final Function(Map<String, dynamic>) onVendorTap;

  const VendorShowcase({
    super.key,
    required this.vendors,
    required this.onVendorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        SizedBox(height: 2.h),
        _buildVendorsList(),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Featured Vendors',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/all-vendor-screen'),
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

  Widget _buildVendorsList() {
    return SizedBox(
      height: 20.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: vendors.length,
        itemBuilder: (context, index) => _buildVendorCard(vendors[index]),
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return GestureDetector(
      onTap: () => onVendorTap(vendor),
      child: Container(
        width: 30.w,
        margin: EdgeInsets.only(right: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVendorAvatar(vendor),
            SizedBox(height: 1.5.h),
            _buildVendorInfo(vendor),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorAvatar(Map<String, dynamic> vendor) {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cardSurfaceLight,
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowBase,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(1.w),
          child: ClipOval(
            child: CustomImageWidget(
              imageUrl: vendor['logo'] as String,
              width: 25.w,
              height: 25.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorInfo(Map<String, dynamic> vendor) {
    return Column(
      children: [
        Text(
          vendor['full_name'] as String,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        if (vendor['rating'] != null) ...[
          SizedBox(height: 0.5.h),
          _buildRatingWidget(vendor['rating']),
        ],
      ],
    );
  }

  Widget _buildRatingWidget(dynamic rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: 'star',
          color: Colors.amber,
          size: 15.sp,
        ),
        SizedBox(width: 1.w),
        Text(
          rating.toString(),
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}