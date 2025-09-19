import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAlldBooks() async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .order('created_at', ascending: false);

      debugPrint('Books response: $response');

      // Map the database fields to the expected keys in the app
      final books = List<Map<String, dynamic>>.from(response).map((book) {
        return {
          'id': book['id'],
          'title': book['title'] ?? 'Unknown Title',
          'author': book['author'] ?? 'Unknown Author',
          'price': '\$${book['price']?.toString() ?? '0.00'}',
          'coverImage': book['cover_url'] ?? '',
          'rating': book['average_rating'] ?? 0.0,
          'description': book['description'] ?? '',
          'category': book['category'] ?? '',
          'vendor_id': book['vendor_id'],
          'publishedDate': book['publication_date']?.toString() ?? '',
          'stock_quantity': book['stock_quantity'] ?? 0,
          'total_reviews': book['total_reviews'] ?? 0,
          'is_featured': book['is_featured'] ?? false,
          'isInWishlist':
              false, // Will be updated when checking wishlist status
          'isAvailable': (book['stock_quantity'] ?? 0) > 0,
        };
      }).toList();

      return books;
    } catch (e) {
      debugPrint('❌ All books error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFeaturedBooks() async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(10);

      debugPrint('Books response: $response');

      // Map the database fields to the expected keys in the app
      final books = List<Map<String, dynamic>>.from(response).map((book) {
        return {
          'id': book['id'],
          'title': book['title'] ?? 'Unknown Title',
          'author': book['author'] ?? 'Unknown Author',
          'price': book['price'],
          'coverImage': book['cover_url'] ?? '',
          'rating': book['average_rating'] ?? 0.0,
          'description': book['description'] ?? '',
          'category': book['category'] ?? '',
          'vendor_id': book['vendor_id'],
          'publication_date': book['publication_date'],
          'stock_quantity': book['stock_quantity'] ?? 0,
          'total_reviews': book['total_reviews'] ?? 0,
          'is_featured': book['is_featured'] ?? false,
          'isInWishlist': false, // Assuming wishlist is handled separately
        };
      }).toList();

      return books;
    } catch (e) {
      debugPrint('❌ Featured books error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      debugPrint('Categories response: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Categories error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getVendors() async {
    try {
      final response = await _supabase
          .from('vendors')
          .select()
          .order('full_name', ascending: true);

      debugPrint('Vendors response: $response');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Vendors error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWishlistBooks(String userId) async {
    try {
      // Join wishlists with books table to get full book data
      final response = await _supabase
          .from('wishlists')
          .select('''
            book_id,
            created_at,
            books!inner (
              id,
              title,
              author,
              price,
              cover_url,
              average_rating,
              description,
              category,
              vendor_id,
              publication_date,
              stock_quantity,
              total_reviews,
              is_featured
            )
          ''')
          .eq('user_id', userId);

      debugPrint('Wishlist response: $response');

      // Map the response to match the expected book format
      final wishlistBooks = List<Map<String, dynamic>>.from(response).map((
        item,
      ) {
        final book = item['books'] as Map<String, dynamic>;
        return {
          'id': book['id'],
          'title': book['title'] ?? 'Unknown Title',
          'author': book['author'] ?? 'Unknown Author',
          'price': '\$${book['price']?.toString() ?? '0.00'}',
          'cover_url': book['cover_url'] ?? '',
          'rating': book['average_rating'] ?? 0.0,
          'description': book['description'] ?? '',
          'category': book['category'] ?? '',
          'vendor_id': book['vendor_id'],
          'publishedDate': book['publication_date']?.toString() ?? '',
          'stock_quantity': book['stock_quantity'] ?? 0,
          'total_reviews': book['total_reviews'] ?? 0,
          'is_featured': book['is_featured'] ?? false,
          'dateAdded': DateTime.parse(item['created_at']),
          'isInWishlist': true,
          'isAvailable': (book['stock_quantity'] ?? 0) > 0,
        };
      }).toList();

      return wishlistBooks;
    } catch (e) {
      debugPrint('❌ Wishlist error: $e');
      rethrow;
    }
  }

  // Add book to wishlist
  Future<void> addToWishlist(String userId, int bookId) async {
    try {
      await _supabase.from('wishlists').insert({
        'user_id': userId,
        'book_id': bookId,
      });
      debugPrint('✅ Book $bookId added to wishlist for user $userId');
    } catch (e) {
      debugPrint('❌ Add to wishlist error: $e');
      rethrow;
    }
  }

  // Remove book from wishlist
  Future<void> removeFromWishlist(String userId, int bookId) async {
    try {
      await _supabase
          .from('wishlists')
          .delete()
          .eq('user_id', userId)
          .eq('book_id', bookId);
      debugPrint('✅ Book $bookId removed from wishlist for user $userId');
    } catch (e) {
      debugPrint('❌ Remove from wishlist error: $e');
      rethrow;
    }
  }

  // Check if book is in wishlist
  Future<bool> isBookInWishlist(String userId, int bookId) async {
    try {
      final response = await _supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('❌ Check wishlist status error: $e');
      return false;
    }
  }

  // Update wishlist status for a list of books
  Future<List<Map<String, dynamic>>> updateBooksWishlistStatus(
    String userId,
    List<Map<String, dynamic>> books,
  ) async {
    if (books.isEmpty || userId.isEmpty) return books;

    try {
      // Get all wishlist items for this user
      final wishlistResponse = await _supabase
          .from('wishlists')
          .select('book_id')
          .eq('user_id', userId);

      final wishlistBookIds = Set<int>.from(
        List<Map<String, dynamic>>.from(
          wishlistResponse,
        ).map((item) => item['book_id'] as int),
      );

      // Update each book's wishlist status
      return books.map((book) {
        final bookId = book['id'] as int;
        return {...book, 'isInWishlist': wishlistBookIds.contains(bookId)};
      }).toList();
    } catch (e) {
      debugPrint('❌ Update books wishlist status error: $e');
      return books; // Return original books if error occurs
    }
  }
}
