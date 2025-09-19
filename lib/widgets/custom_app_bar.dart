import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? showBackButton;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showElevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton,
    this.leading,
    this.actions,
    this.showElevation = false,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.bottom,
  });

  factory CustomAppBar.home({
    Key? key,
    String title = 'BookStore',
    VoidCallback? onSearchTap,
    VoidCallback? onProfileTap,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      showBackButton: false,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed:
                onSearchTap ??
                () {
                  Navigator.pushNamed(context, '/category-screen');
                },
            tooltip: 'Search books',
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed:
                onProfileTap ??
                () {
                  Navigator.pushNamed(context, '/profile-screen');
                },
            tooltip: 'Profile',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  factory CustomAppBar.category({
    Key? key,
    String title = 'Categories',
    VoidCallback? onFilterTap,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed:
                onFilterTap ??
                () {
                  _showFilterBottomSheet(context);
                },
            tooltip: 'Filter',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  factory CustomAppBar.bookDetail({
    Key? key,
    String title = 'Book Details',
    VoidCallback? onWishlistTap,
    VoidCallback? onShareTap,
    bool isInWishlist = false,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(
              isInWishlist
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isInWishlist
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed:
                onWishlistTap ??
                () {
                  Navigator.pushNamed(context, '/wishlist-screen');
                },
            tooltip: isInWishlist ? 'Remove from wishlist' : 'Add to wishlist',
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed:
                onShareTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon'),
                    ),
                  );
                },
            tooltip: 'Share',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  factory CustomAppBar.wishlist({
    Key? key,
    String title = 'My Wishlist',
    VoidCallback? onClearTap,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: [
        Builder(
          builder: (context) => TextButton(
            onPressed:
                onClearTap ??
                () {
                  _showClearWishlistDialog(context);
                },
            child: Text(
              'Clear',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  factory CustomAppBar.profile({
    Key? key,
    String title = 'Profile',
    VoidCallback? onSettingsTap,
  }) {
    return CustomAppBar(key: key, title: title);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final shouldShowBackButton =
        showBackButton ??
        (leading == null && ModalRoute.of(context)?.canPop == true);

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onSurface,
          letterSpacing: 0.15,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: showElevation ? 2 : 0,
      scrolledUnderElevation: showElevation ? 4 : 2,
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow,
      leading:
          leading ??
          (shouldShowBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                )
              : null),
      actions: actions,
      bottom: bottom,
      iconTheme: IconThemeData(
        color: foregroundColor ?? colorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: foregroundColor ?? colorScheme.onSurface,
        size: 24,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  static void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filter Books',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filter options will be implemented here',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  static void _showClearWishlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Wishlist',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to remove all books from your wishlist? This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Wishlist cleared')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
