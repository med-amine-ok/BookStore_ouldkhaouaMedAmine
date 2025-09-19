import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class BookCardWidget extends StatefulWidget {
  final Map<String, dynamic> book;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onLongPress;

  const BookCardWidget({
    super.key,
    required this.book,
    this.onTap,
    this.onWishlistTap,
    this.onLongPress,
  });

  @override
  State<BookCardWidget> createState() => _BookCardWidgetState();
}

class _BookCardWidgetState extends State<BookCardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _heartController;
  late final Animation<double> _heartAnimation;
  late final AnimationController _cardController;
  late final Animation<double> _cardAnimation;
  late bool _isInWishlist;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );

    _isInWishlist = widget.book['isInWishlist'] ?? false;
    _cardController.forward();
  }

  @override
  void dispose() {
    _heartController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _toggleWishlist() {
    setState(() => _isInWishlist = !_isInWishlist);
    _heartController.forward().then((_) => _heartController.reverse());
    widget.onWishlistTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.lightTheme.colorScheme;

    return ScaleTransition(
      scale: _cardAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'book_${widget.book['id']}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CustomImageWidget(
                          imageUrl: widget.book['coverImage'] ?? '',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: GestureDetector(
                        onTap: _toggleWishlist,
                        child: AnimatedBuilder(
                          animation: _heartAnimation,
                          builder: (context, child) => Transform.scale(
                            scale: _heartAnimation.value,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: colors.surface.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.shadow.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CustomIconWidget(
                                iconName: _isInWishlist
                                    ? 'favorite'
                                    : 'favorite_border',
                                color: _isInWishlist
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                                size: 5.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book['title'] ?? 'Unknown Title',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        widget.book['author'] ?? 'Unknown Author',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.book['price']?.toString() ?? '0.00'}',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                              letterSpacing: 0.15,
                            ),
                          ),
                          if (widget.book['rating'] != null)
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: Colors.amber,
                                  size: 4.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  widget.book['rating'].toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                        ],
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
}
