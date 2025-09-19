import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchOverlay extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClose;

  const SearchOverlay({
    super.key,
    required this.onSearch,
    required this.onClose,
  });

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _recentSearches = [
    'Fiction Books',
    'Stephen King',
    'Romance Novels',
    'Science Fiction',
    'Biography',
  ];

  final List<String> _popularSearches = [
    'Best Sellers',
    'New Releases',
    'Mystery & Thriller',
    'Self Help',
    'Children Books',
    'Cooking',
    'History',
    'Fantasy',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      widget.onSearch(query.trim());
      _closeOverlay();
    }
  }

  void _closeOverlay() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: AppTheme.primaryBackgroundLight.withValues(
            alpha: 0.95 * _fadeAnimation.value,
          ),
          child: SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Search Header
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurfaceLight,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowBase,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _closeOverlay,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              child: CustomIconWidget(
                                iconName: 'arrow_back_ios',
                                color: AppTheme.textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.borderSubtle.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                onSubmitted: _handleSearch,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search books, authors, categories...',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textMuted,
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'search',
                                      color: AppTheme.textMuted,
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(3.w),
                                            child: CustomIconWidget(
                                              iconName: 'clear',
                                              color: AppTheme.textMuted,
                                              size: 20,
                                            ),
                                          ),
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 3.w,
                                  ),
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recent Searches
                            if (_recentSearches.isNotEmpty) ...[
                              Text(
                                'Recent Searches',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Wrap(
                                spacing: 2.w,
                                runSpacing: 1.h,
                                children: _recentSearches.map((search) {
                                  return GestureDetector(
                                    onTap: () => _handleSearch(search),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 1.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardSurfaceLight,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.borderSubtle,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CustomIconWidget(
                                            iconName: 'history',
                                            color: AppTheme.textMuted,
                                            size: 16,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            search,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 3.h),
                            ],

                            // Popular Searches
                            Text(
                              'Popular Searches',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Wrap(
                              spacing: 2.w,
                              runSpacing: 1.h,
                              children: _popularSearches.map((search) {
                                return GestureDetector(
                                  onTap: () => _handleSearch(search),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.CafeAccent.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.CafeAccent.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'trending_up',
                                          color: AppTheme.CafeAccent,
                                          size: 16,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          search,
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.CafeAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
