import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';


class WishlistItemWidget extends StatefulWidget {
  final Map<String, dynamic> book;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool isEditMode;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const WishlistItemWidget({
    super.key,
    required this.book,
    this.onRemove,
    this.onTap,
    this.isEditMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  State<WishlistItemWidget> createState() => _WishlistItemWidgetState();
}

class _WishlistItemWidgetState extends State<WishlistItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleRemove() async {
    if (_isRemoving) return;

    setState(() {
      _isRemoving = true;
    });

    // Show confirmation dialog
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove from Wishlist',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${widget.book["title"]}" from your wishlist?',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.cardSurfaceLight,
            ),
            child: Text(
              'Remove',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    setState(() {
      _isRemoving = false;
    });

    if (shouldRemove == true && widget.onRemove != null) {
      // Animate removal
      await _animationController.forward();
      widget.onRemove!();
    }
  }

  void _handleTap() {
    if (widget.isEditMode) {
      widget.onSelectionChanged?.call(!widget.isSelected);
    } else {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.cardSurfaceLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowBase,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Dismissible(
              key: Key('wishlist_${widget.book["id"]}'),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.cardSurfaceLight,
                      size: 24,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Remove',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cardSurfaceLight,
                      ),
                    ),
                  ],
                ),
              ),
              onDismissed: (direction) {
                widget.onRemove?.call();
              },
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleTap,
                  onLongPress: widget.isEditMode
                      ? null
                      : () {
                          _showContextMenu();
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        // Selection checkbox (edit mode)
                        if (widget.isEditMode) ...[
                          Checkbox(
                            value: widget.isSelected,
                            onChanged: (bool? value) {
                              if (value != null) {
                                widget.onSelectionChanged?.call(value);
                              }
                            },
                            activeColor: AppTheme.CafeAccent,
                          ),
                          SizedBox(width: 3.w),
                        ],

                        // Book cover
                        Hero(
                          tag: 'book_cover_${widget.book["id"]}',
                          child: Container(
                            width: 20.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowBase,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CustomImageWidget(
                                imageUrl: widget.book["cover_url"] as String,
                                width: 20.w,
                                height: 12.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 4.w),

                        // Book details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book["title"] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'by ${widget.book["author"]}',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Text(
                                    widget.book["price"] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.CafeAccent,
                                    ),
                                  ),
                                  if (widget.book["originalPrice"] != null) ...[
                                    SizedBox(width: 2.w),
                                    Text(
                                      widget.book["originalPrice"] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppTheme.textMuted,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (widget.book["availability"] != null) ...[
                                SizedBox(height: 0.5.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (widget.book["availability"] as String)
                                                .toLowerCase() ==
                                            'in stock'
                                        ? AppTheme.successGreen.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppTheme.errorRed.withValues(
                                            alpha: 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.book["availability"] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          (widget.book["availability"]
                                                      as String)
                                                  .toLowerCase() ==
                                              'in stock'
                                          ? AppTheme.successGreen
                                          : AppTheme.errorRed,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Remove button (non-edit mode)
                        if (!widget.isEditMode) ...[
                          SizedBox(width: 2.w),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isRemoving ? null : _handleRemove,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(2.w),
                                child: _isRemoving
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppTheme.errorRed,
                                              ),
                                        ),
                                      )
                                    : CustomIconWidget(
                                        iconName: 'favorite',
                                        color: AppTheme.errorRed,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardSurfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            SizedBox(height: 3.h),

            // Book info
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 9.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: widget.book["cover_url"] as String,
                      width: 15.w,
                      height: 9.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book["title"] as String,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'by ${widget.book["author"]}',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Action buttons
            _buildActionButton(
              icon: 'shopping_cart',
              label: 'Move to Cart',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added to cart: ${widget.book["title"]}'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
            ),

            SizedBox(height: 2.h),

            _buildActionButton(
              icon: 'share',
              label: 'Share',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share functionality coming soon'),
                  ),
                );
              },
            ),

            SizedBox(height: 2.h),

            _buildActionButton(
              icon: 'delete',
              label: 'Remove from Wishlist',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _handleRemove();
              },
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDestructive ? AppTheme.errorRed : AppTheme.borderSubtle,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: isDestructive ? AppTheme.errorRed : AppTheme.textPrimary,
                size: 24,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? AppTheme.errorRed
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
