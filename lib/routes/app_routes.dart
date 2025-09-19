import 'package:flutter/material.dart';
import '../presentation/wishlist_screen/wishlist_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/book_detail_screen/book_detail_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/sign_up_screen/sign_up_screen.dart';
import '../presentation/category_screen/category_screen.dart';
import '../presentation/sign_in_screen/sign_in_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/onboarding_screen/splash_screen.dart';
import '../presentation/all_vendor_screen/all_vendor.dart';
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
  };
}
