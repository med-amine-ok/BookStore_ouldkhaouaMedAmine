import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data class for bottom navigation
class NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom Bottom Navigation Bar implementing Contemporary Literary Minimalism
/// Provides adaptive navigation with gesture-aware interactions
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int>? onTap;

  /// Whether to use modern NavigationBar instead of BottomNavigationBar
  final bool useModernStyle;

  /// Background color override
  final Color? backgroundColor;

  /// Selected item color override
  final Color? selectedItemColor;

  /// Unselected item color override
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.useModernStyle = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  /// Predefined navigation items for the bookstore app
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: '/home-screen',
    ),
    NavigationItem(
      icon: Icons.category_outlined,
      activeIcon: Icons.category_rounded,
      label: 'Categories',
      route: '/category-screen',
    ),
    NavigationItem(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Wishlist',
      route: '/wishlist-screen',
    ),
    NavigationItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: '/profile-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle navigation tap
    void handleTap(int index) {
      if (onTap != null) {
        onTap!(index);
      } else {
        // Default navigation behavior
        final route = _navigationItems[index].route;
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            route,
            (route) => false,
          );
        }
      }
    }

    if (useModernStyle) {
      return _buildNavigationBar(context, theme, colorScheme, handleTap);
    } else {
      return _buildBottomNavigationBar(context, theme, colorScheme, handleTap);
    }
  }

  /// Build modern NavigationBar (Material 3 style)
  Widget _buildNavigationBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    ValueChanged<int> handleTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: handleTap,
          backgroundColor: backgroundColor ?? colorScheme.surface,
          indicatorColor:
              (selectedItemColor ?? colorScheme.primary).withAlpha(26),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 80,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;

            return NavigationDestination(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? (selectedItemColor ?? colorScheme.primary)
                      : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
                  size: 24,
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Build classic BottomNavigationBar
  Widget _buildBottomNavigationBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    ValueChanged<int> handleTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: handleTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundColor ?? colorScheme.surface,
          selectedItemColor: selectedItemColor ?? colorScheme.primary,
          unselectedItemColor:
              unselectedItemColor ?? colorScheme.onSurfaceVariant,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
          items: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;

            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (selectedItemColor ?? colorScheme.primary).withAlpha(26)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 24,
                ),
              ),
              label: item.label,
              tooltip: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Factory constructor for home screen bottom bar
  factory CustomBottomBar.home({
    Key? key,
    ValueChanged<int>? onTap,
    bool useModernStyle = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: 0,
      onTap: onTap,
      useModernStyle: useModernStyle,
    );
  }

  /// Factory constructor for category screen bottom bar
  factory CustomBottomBar.category({
    Key? key,
    ValueChanged<int>? onTap,
    bool useModernStyle = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: 1,
      onTap: onTap,
      useModernStyle: useModernStyle,
    );
  }

  /// Factory constructor for wishlist screen bottom bar
  factory CustomBottomBar.wishlist({
    Key? key,
    ValueChanged<int>? onTap,
    bool useModernStyle = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: 2,
      onTap: onTap,
      useModernStyle: useModernStyle,
    );
  }

  /// Factory constructor for profile screen bottom bar
  factory CustomBottomBar.profile({
    Key? key,
    ValueChanged<int>? onTap,
    bool useModernStyle = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: 3,
      onTap: onTap,
      useModernStyle: useModernStyle,
    );
  }

  /// Get the route for a specific index
  static String getRouteForIndex(int index) {
    if (index >= 0 && index < _navigationItems.length) {
      return _navigationItems[index].route;
    }
    return '/home-screen';
  }

  /// Get the index for a specific route
  static int getIndexForRoute(String route) {
    for (int i = 0; i < _navigationItems.length; i++) {
      if (_navigationItems[i].route == route) {
        return i;
      }
    }
    return 0; // Default to home
  }

  /// Get all available routes
  static List<String> get allRoutes {
    return _navigationItems.map((item) => item.route).toList();
  }
}
