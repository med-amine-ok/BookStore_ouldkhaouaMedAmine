import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';


class WishlistSearchWidget extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClear;

  const WishlistSearchWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onClear,
  });

  @override
  State<WishlistSearchWidget> createState() => _WishlistSearchWidgetState();
}

class _WishlistSearchWidgetState extends State<WishlistSearchWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _searchController.clear();
      widget.onSearchChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isExpanded ? 7.h : 6.h,
        decoration: BoxDecoration(
          color: AppTheme.cardSurfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowBase,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isExpanded ? _buildExpandedSearch() : _buildCollapsedSearch(),
      ),
    );
  }

  Widget _buildCollapsedSearch() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleSearch,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'search',
                color: AppTheme.textSecondary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Search your wishlist...',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              if (widget.searchQuery.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.CafeAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.searchQuery.length > 10 ? '${widget.searchQuery.substring(0, 10)}...' : widget.searchQuery}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cardSurfaceLight,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
              ],
              CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedSearch() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by title or author...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.CafeAccent,
                      size: 24,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                onChanged: widget.onSearchChanged,
                textInputAction: TextInputAction.search,
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              SizedBox(width: 2.w),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: CustomIconWidget(
                      iconName: 'clear',
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(width: 2.w),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleSearch,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.w),
                  child: CustomIconWidget(
                    iconName: 'keyboard_arrow_up',
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
