import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'widgets/avatar_selection_bottom_sheet.dart';
import 'widgets/order_history_item_widget.dart';
import 'widgets/preference_chip_widget.dart';
import 'widgets/profile_field_widget.dart';
import 'widgets/profile_header_widget.dart';
import 'widgets/setting_item_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = '';
  String _userEmail = '';
  String _userPhone = '';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _fullName = user.userMetadata?['full_name'] ?? '';
      _userEmail = user.email ?? '';
      _userPhone = user.userMetadata?['phone_number'] ?? '';
      _avatarUrl = user.userMetadata?['avatar_url'] ?? '';
    }

    _loadUserProfile();
  }

  // Load profile from Supabase table to get avatar_url/full_name/phone
  Future<void> _loadUserProfile() async {
    try {
      final authService = AuthService();
      final profile = await authService.getUserProfile();
      if (!mounted || profile == null) return;

      setState(() {
        final name = profile['full_name'];
        final phone = profile['phone_number'];
        final avatar = profile['avatar_url'];
        if (name is String && name.isNotEmpty) _fullName = name;
        if (phone is String && phone.isNotEmpty) _userPhone = phone;
        if (avatar is String && avatar.isNotEmpty) _avatarUrl = avatar;
      });
    } catch (_) {
    }
  }

  static const List<String> _availableCategories = [
    'Fiction',
    'Non-Fiction',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Biography',
    'History',
    'Fantasy',
    'Thriller',
    'Self-Help',
  ];

  final Set<String> _selectedCategories = {'Fiction', 'Mystery', 'Biography'};

  final Map<String, bool> _notificationSettings = {
    'emailNotifications': true,
    'pushNotifications': true,
    'orderUpdates': true,
    'newReleases': false,
  };

  bool _isAccountSectionExpanded = false;
  bool _isPreferencesSectionExpanded = false;
  bool _isOrdersSectionExpanded = false;
  bool _isSettingsSectionExpanded = false;

  static const List<Map<String, dynamic>> _orderHistory = [
    {
      "orderId": "BZ2024001",
      "bookTitle": "The Seven Husbands of Evelyn Hugo",
      "bookAuthor": "Taylor Jenkins Reid",
      "bookImage":
          "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&h=400&fit=crop",
      "price": "\$16.99",
      "orderDate": "Dec 15, 2024",
      "status": "Delivered",
    },
    {
      "orderId": "BZ2024002",
      "bookTitle": "Atomic Habits",
      "bookAuthor": "James Clear",
      "bookImage":
          "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=300&h=400&fit=crop",
      "price": "\$18.99",
      "orderDate": "Dec 10, 2024",
      "status": "Shipped",
    },
    {
      "orderId": "BZ2024003",
      "bookTitle": "Where the Crawdads Sing",
      "bookAuthor": "Delia Owens",
      "bookImage":
          "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=300&h=400&fit=crop",
      "price": "\$15.99",
      "orderDate": "Dec 5, 2024",
      "status": "Processing",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      appBar: CustomAppBar.profile(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 3.h),
            _buildAccountInformationSection(),
            _buildReadingPreferencesSection(),
            _buildOrderHistorySection(),
            _buildSettingsSection(),
            _buildLogoutButton(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar.profile(),
    );
  }

  Widget _buildProfileHeader() {
    return ProfileHeaderWidget(
      fullName: _fullName,
      userEmail: _userEmail,
      avatarUrl: _avatarUrl,
      onAvatarTap: _handleAvatarSelection,
    );
  }

  Widget _buildAccountInformationSection() {
    return _buildExpandableSection(
      title: 'Account Information',
      isExpanded: _isAccountSectionExpanded,
      onToggle: () => setState(
        () => _isAccountSectionExpanded = !_isAccountSectionExpanded,
      ),
      children: [
        ProfileFieldWidget(
          label: 'Full Name',
          value: _fullName,
          isRequired: true,
          validator: _validateName,
          onChanged: (value) => setState(() => _fullName = value),
        ),
        ProfileFieldWidget(
          label: 'Email',
          value: _userEmail,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
          validator: _validateEmail,
          onChanged: (value) => setState(() => _userEmail = value),
        ),
        ProfileFieldWidget(
          label: 'Phone Number',
          value: _userPhone,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
          onChanged: (value) => setState(() => _userPhone = value),
        ),
      ],
    );
  }

  Widget _buildReadingPreferencesSection() {
    return _buildExpandableSection(
      title: 'Reading Preferences',
      isExpanded: _isPreferencesSectionExpanded,
      onToggle: () => setState(
        () => _isPreferencesSectionExpanded = !_isPreferencesSectionExpanded,
      ),
      children: [
        _buildCategorySelection(),
        SizedBox(height: 2.h),
        _buildNotificationSettings(),
      ],
    );
  }

  Widget _buildOrderHistorySection() {
    return _buildExpandableSection(
      title: 'Recent Orders',
      isExpanded: _isOrdersSectionExpanded,
      onToggle: () =>
          setState(() => _isOrdersSectionExpanded = !_isOrdersSectionExpanded),
      children: [
        ..._orderHistory.take(2).map(_buildOrderItem),
        if (_orderHistory.length > 2) ...[
          SizedBox(height: 1.h),
          _buildViewAllOrdersButton(),
        ],
      ],
    );
  }

  Widget _buildSettingsSection() {
    return _buildExpandableSection(
      title: 'Settings',
      isExpanded: _isSettingsSectionExpanded,
      onToggle: () => setState(
        () => _isSettingsSectionExpanded = !_isSettingsSectionExpanded,
      ),
      children: [
        SettingItemWidget(
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          iconName: 'privacy_tip',
          onTap: () => _showToast('Opening Privacy Policy'),
        ),
        SettingItemWidget(
          title: 'Terms of Service',
          subtitle: 'View terms and conditions',
          iconName: 'description',
          onTap: () => _showToast('Opening Terms of Service'),
        ),
        SettingItemWidget(
          title: 'Help & Support',
          subtitle: 'Get help or contact support',
          iconName: 'help_outline',
          onTap: () => _showToast('Opening Help & Support'),
        ),
        SettingItemWidget(
          title: 'About BookStore',
          subtitle: 'Learn more about us',
          iconName: 'info_outline',
          onTap: _showAboutDialog,
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Container(
                    padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
                    child: Column(children: children),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Categories',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          children: _availableCategories.map((category) {
            return PreferenceChipWidget(
              label: category,
              isSelected: _selectedCategories.contains(category),
              onTap: () => _toggleCategory(category),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    const notificationData = {
      'emailNotifications': {
        'title': 'Email Notifications',
        'subtitle': 'Receive updates via email',
      },
      'pushNotifications': {
        'title': 'Push Notifications',
        'subtitle': 'Receive push notifications on your device',
      },
      'orderUpdates': {
        'title': 'Order Updates',
        'subtitle': 'Get notified about order status changes',
      },
      'newReleases': {
        'title': 'New Releases',
        'subtitle': 'Be the first to know about new book releases',
      },
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        ...notificationData.entries.map((entry) {
          final key = entry.key;
          final data = entry.value;
          return _buildNotificationToggle(
            data['title']!,
            data['subtitle']!,
            _notificationSettings[key]!,
            (value) => setState(() => _notificationSettings[key] = value),
          );
        }),
      ],
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return OrderHistoryItemWidget(
      orderId: order["orderId"] as String,
      bookTitle: order["bookTitle"] as String,
      bookAuthor: order["bookAuthor"] as String,
      bookImage: order["bookImage"] as String,
      price: order["price"] as String,
      orderDate: order["orderDate"] as String,
      status: order["status"] as String,
      onTap: () => _showToast('Order details for ${order["orderId"]}'),
    );
  }

  Widget _buildViewAllOrdersButton() {
    return InkWell(
      onTap: () => _showToast('Viewing all orders'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'View All Orders (${_orderHistory.length})',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 2.h, bottom: 4.h),
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorRed,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'logout',
              size: 5.w,
              color: Colors.white,
            ),
            SizedBox(width: 2.w),
            Text(
              'Logout',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAvatarSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: 90.h,
        child: AvatarSelectionBottomSheet(
          onImageSelected: (imageUrl) async {
            setState(() {
              _avatarUrl = imageUrl.isNotEmpty ? imageUrl : null;
            });
            _showToast('Profile photo updated successfully');
            await _loadUserProfile(); 
          },
        ),
      ),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    _showToast('Preferences updated');
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'menu_book',
              size: 6.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            const Text('BookStore'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Version',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your premier destination for discovering and purchasing books. Built with Flutter for a seamless reading experience.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              '© 2025 BookStore. All rights reserved.',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'logout',
              size: 6.w,
              color: AppTheme.errorRed,
            ),
            SizedBox(width: 2.w),
            const Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    final authService = AuthService();
    authService.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/sign-in-screen',
      (route) => false,
    );
    _showToast('Logged out successfully');
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successGreen,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}