import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab item data class for custom tab bar
class TabItem {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final String? route;
  final Map<String, dynamic>? routeArguments;

  const TabItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.route,
    this.routeArguments,
  });
}

/// Custom Tab Bar implementing Contemporary Literary Minimalism
/// Provides clean, sophisticated tab navigation for content categorization
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// List of tab items
  final List<TabItem> tabs;

  /// Current selected tab index
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int>? onTap;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Tab alignment when not scrollable
  final TabAlignment tabAlignment;

  /// Background color override
  final Color? backgroundColor;

  /// Selected tab color override
  final Color? selectedColor;

  /// Unselected tab color override
  final Color? unselectedColor;

  /// Indicator color override
  final Color? indicatorColor;

  /// Whether to show icons in tabs
  final bool showIcons;

  /// Custom indicator decoration
  final Decoration? indicator;

  /// Tab controller (optional, for advanced usage)
  final TabController? controller;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.currentIndex = 0,
    this.onTap,
    this.isScrollable = false,
    this.tabAlignment = TabAlignment.fill,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.showIcons = false,
    this.indicator,
    this.controller,
  });

  /// Factory constructor for book categories tab bar
  factory CustomTabBar.bookCategories({
    Key? key,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      controller: controller,
      isScrollable: true,
      tabs: const [
        TabItem(
          label: 'All Books',
          icon: Icons.library_books_outlined,
        ),
        TabItem(
          label: 'Fiction',
          icon: Icons.auto_stories_outlined,
        ),
        TabItem(
          label: 'Non-Fiction',
          icon: Icons.fact_check_outlined,
        ),
        TabItem(
          label: 'Mystery',
          icon: Icons.search_outlined,
        ),
        TabItem(
          label: 'Romance',
          icon: Icons.favorite_border_outlined,
        ),
        TabItem(
          label: 'Sci-Fi',
          icon: Icons.rocket_launch_outlined,
        ),
        TabItem(
          label: 'Biography',
          icon: Icons.person_outline_rounded,
        ),
        TabItem(
          label: 'History',
          icon: Icons.history_edu_outlined,
        ),
      ],
      showIcons: true,
    );
  }

  /// Factory constructor for book sorting tab bar
  factory CustomTabBar.bookSorting({
    Key? key,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      controller: controller,
      isScrollable: true,
      tabs: const [
        TabItem(label: 'Popular'),
        TabItem(label: 'New Releases'),
        TabItem(label: 'Best Sellers'),
        TabItem(label: 'Price: Low to High'),
        TabItem(label: 'Price: High to Low'),
        TabItem(label: 'Rating'),
        TabItem(label: 'A-Z'),
        TabItem(label: 'Z-A'),
      ],
    );
  }

  /// Factory constructor for profile sections tab bar
  factory CustomTabBar.profileSections({
    Key? key,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      controller: controller,
      tabs: const [
        TabItem(
          label: 'Reading',
          icon: Icons.menu_book_outlined,
        ),
        TabItem(
          label: 'Completed',
          icon: Icons.check_circle_outline,
        ),
        TabItem(
          label: 'Reviews',
          icon: Icons.rate_review_outlined,
        ),
      ],
      showIcons: true,
    );
  }

  /// Factory constructor for wishlist filters tab bar
  factory CustomTabBar.wishlistFilters({
    Key? key,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      controller: controller,
      isScrollable: true,
      tabs: const [
        TabItem(label: 'All'),
        TabItem(label: 'Available'),
        TabItem(label: 'Pre-order'),
        TabItem(label: 'On Sale'),
        TabItem(label: 'Recently Added'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle tab selection
    void handleTap(int index) {
      if (onTap != null) {
        onTap!(index);
      } else if (tabs[index].route != null) {
        // Navigate to route if specified
        Navigator.pushNamed(
          context,
          tabs[index].route!,
          arguments: tabs[index].routeArguments,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        onTap: handleTap,
        isScrollable: isScrollable,
        tabAlignment: tabAlignment,
        labelColor: selectedColor ?? colorScheme.primary,
        unselectedLabelColor: unselectedColor ?? colorScheme.onSurfaceVariant,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        indicator: indicator ??
            UnderlineTabIndicator(
              borderSide: BorderSide(
                color: indicatorColor ?? colorScheme.primary,
                width: 2,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 16),
            ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        labelPadding: EdgeInsets.symmetric(
          horizontal: isScrollable ? 16 : 8,
          vertical: 8,
        ),
        overlayColor: WidgetStateProperty.all(
          (selectedColor ?? colorScheme.primary).withAlpha(26),
        ),
        splashFactory: InkRipple.splashFactory,
        tabs: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == currentIndex;

          return Tab(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected && !isScrollable
                    ? (selectedColor ?? colorScheme.primary).withAlpha(26)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showIcons &&
                      (tab.icon != null || tab.customIcon != null)) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: tab.customIcon ??
                          Icon(
                            tab.icon,
                            size: 18,
                            color: isSelected
                                ? (selectedColor ?? colorScheme.primary)
                                : (unselectedColor ??
                                    colorScheme.onSurfaceVariant),
                            key: ValueKey('${tab.label}_$isSelected'),
                          ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      tab.label,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: 0.1,
                        color: isSelected
                            ? (selectedColor ?? colorScheme.primary)
                            : (unselectedColor ?? colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight + 16);

  /// Create a TabController with the appropriate length
  static TabController createController({
    required TickerProvider vsync,
    required int length,
    int initialIndex = 0,
  }) {
    return TabController(
      length: length,
      initialIndex: initialIndex,
      vsync: vsync,
    );
  }

  /// Get tab count for controller creation
  int get tabCount => tabs.length;

  /// Get tab labels for external use
  List<String> get tabLabels => tabs.map((tab) => tab.label).toList();

  /// Check if tab has icon
  bool hasIconAtIndex(int index) {
    if (index < 0 || index >= tabs.length) return false;
    return tabs[index].icon != null || tabs[index].customIcon != null;
  }

  /// Get tab route if available
  String? getRouteAtIndex(int index) {
    if (index < 0 || index >= tabs.length) return null;
    return tabs[index].route;
  }
}

/// Custom Tab Indicator for more sophisticated styling
class CustomTabIndicator extends Decoration {
  final Color color;
  final double height;
  final double radius;
  final EdgeInsets insets;

  const CustomTabIndicator({
    required this.color,
    this.height = 3,
    this.radius = 1.5,
    this.insets = EdgeInsets.zero,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      color: color,
      height: height,
      radius: radius,
      insets: insets,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double height;
  final double radius;
  final EdgeInsets insets;

  _CustomTabIndicatorPainter({
    required this.color,
    required this.height,
    required this.radius,
    required this.insets,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = Rect.fromLTWH(
      offset.dx + insets.left,
      configuration.size!.height - height - insets.bottom,
      configuration.size!.width - insets.left - insets.right,
      height,
    );

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }
}
