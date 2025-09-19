import 'package:flutter/material.dart';
import '../screens/wishlist_screen/wishlist_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
import '../screens/book_detail_screen/book_detail_screen.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/sign_up_screen/sign_up_screen.dart';
import '../screens/category_screen/category_screen.dart';
import '../screens/sign_in_screen/sign_in_screen.dart';
import '../screens/onboarding_screen/onboarding_screen.dart';
import '../screens/onboarding_screen/splash_screen.dart';
import '../screens/all_vendor_screen/all_vendor.dart';
import '../screens/forgot_password_screen/forgot_password_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String onboarding = '/onboarding-screen';
  static const String signUp = '/sign-up-screen';
  static const String signIn = '/sign-in-screen';
  static const String home = '/home-screen';
  static const String category = '/category-screen';
  static const String wishlist = '/wishlist-screen';
  static const String profile = '/profile-screen';
  static const String bookDetail = '/book-detail-screen';
  static const String allVendor = '/all-vendor-screen';
  static const String forgotPassword = '/forgot-password-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    wishlist: (context) => const WishlistScreen(),
    profile: (context) => const ProfileScreen(),
    bookDetail: (context) => const BookDetailScreen(),
    home: (context) => const HomeScreen(),
    signUp: (context) => const SignUpScreen(),
    signIn: (context) => const SignInScreen(),
    category: (context) => const CategoryScreen(),
    allVendor: (context) => const AllVendorScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
  };
}
