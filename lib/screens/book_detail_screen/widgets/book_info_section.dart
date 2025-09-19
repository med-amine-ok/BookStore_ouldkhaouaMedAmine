import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../../../services/data_service.dart';

/// Book information section with title, author, price, and rating
class BookInfoSection extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookInfoSection({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Title
          Text(
            book['title'] as String,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),

          // Author
          Text(
            'by ${book['author'] as String}',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),

          // Rating and Reviews
          Row(
            children: [
              _buildStarRating(book['rating'] as double),
              SizedBox(width: 2.w),
              Text(
                '${book['rating']}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(width: 2.w),          
            ],
          ),
          SizedBox(height: 3.h),

          // Price Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book['originalPrice'] != null &&
                      book['originalPrice'] != book['price']) ...[
                    Text(
                      '\$${book['originalPrice']}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                  ],
                  Text(
                    '\$${book['price']}',
                    style: AppTheme.lightTheme.textTheme.headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.CafeAccent,
                        ),
                  ),
                ],
              ),

              // Wishlist Button
              _WishlistButton(bookId: book['id'] as int),
            ],
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
}

/// Animated wishlist button with heart toggle
class _WishlistButton extends StatefulWidget {
  final int bookId;

  const _WishlistButton({required this.bookId});

  @override
  State<_WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<_WishlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInWishlist = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Check if book is in wishlist
    _checkWishlistStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkWishlistStatus() async {
    if (!_authService.isAuthenticated || _authService.currentUser == null) {
      return;
    }

    try {
      final userId = _authService.currentUser!.id;
      final isInWishlist = await _dataService.isBookInWishlist(
        userId,
        widget.bookId,
      );

      if (mounted) {
        setState(() {
          _isInWishlist = isInWishlist;
        });
      }
    } catch (e) {
      debugPrint('Error checking wishlist status: $e');
    }
  }

  Future<void> _toggleWishlist() async {
    if (!_authService.isAuthenticated || _authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add to wishlist'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);

    final userId = _authService.currentUser!.id;
    final wasInWishlist = _isInWishlist;

    try {
      if (_isInWishlist) {
        await _dataService.removeFromWishlist(userId, widget.bookId);
        setState(() => _isInWishlist = false);
      } else {
        await _dataService.addToWishlist(userId, widget.bookId);
        setState(() => _isInWishlist = true);
      }

      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: _isInWishlist
              ? AppTheme.successGreen
              : AppTheme.textPrimary,
        ),
      );
    } catch (e) {
      // Revert the state if operation failed
      setState(() => _isInWishlist = wasInWishlist);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update wishlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error toggling wishlist: $e');
    } finally {
      setState(() => _isLoading = false);
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
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _isInWishlist
                  ? AppTheme.CafeAccent.withValues(alpha: 0.1)
                  : AppTheme.cardSurfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isInWishlist
                    ? AppTheme.CafeAccent
                    : AppTheme.borderSubtle,
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _toggleWishlist,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _isInWishlist
                            ? AppTheme.CafeAccent
                            : AppTheme.textSecondary,
                      ),
                    )
                  : CustomIconWidget(
                      iconName: _isInWishlist ? 'favorite' : 'favorite_border',
                      color: _isInWishlist
                          ? AppTheme.CafeAccent
                          : AppTheme.textSecondary,
                      size: 20,
                    ),
              padding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }
}
