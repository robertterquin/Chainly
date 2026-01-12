import 'package:supabase_flutter/supabase_flutter.dart';

/// Cycling Tip Model
class CyclingTip {
  final String id;
  final String title;
  final String tipText;
  final String source;
  final String? sourceUrl;
  final String? category;

  CyclingTip({
    required this.id,
    required this.title,
    required this.tipText,
    required this.source,
    this.sourceUrl,
    this.category,
  });

  factory CyclingTip.fromJson(Map<String, dynamic> json) {
    return CyclingTip(
      id: json['id'] as String,
      title: json['title'] as String,
      tipText: json['tip_text'] as String,
      source: json['source'] as String,
      sourceUrl: json['source_url'] as String?,
      category: json['category'] as String?,
    );
  }
}

/// Cycling Tips Service
/// Fetches daily cycling tips from Supabase
class CyclingTipsService {
  final SupabaseClient _client;
  static const String _tableName = 'cycling_tips';

  CyclingTipsService(this._client);

  /// Get a random daily tip based on the current date
  /// Same tip will be returned for the entire day
  Future<CyclingTip> getDailyTip() async {
    try {
      // Get all tips first
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: true);
      
      final tips = (response as List).map((json) => CyclingTip.fromJson(json)).toList();
      final totalTips = tips.length;
      
      if (totalTips == 0) {
        throw Exception('No tips available');
      }

      // Calculate index based on current date (changes daily)
      final now = DateTime.now();
      final daysSinceEpoch = now.difference(DateTime(2024, 1, 1)).inDays;
      final tipIndex = daysSinceEpoch % totalTips;

      // Return the tip at the calculated index
      return tips[tipIndex];
    } catch (e) {
      // Fallback tip if database fetch fails
      return CyclingTip(
        id: 'fallback',
        title: 'Tip of the Day',
        tipText: 'Clean your chain every 200-300km to extend its lifespan and maintain smooth shifting.',
        source: 'BikeRadar',
        sourceUrl: 'https://www.bikeradar.com/advice/workshop/how-to-clean-a-bike-chain/',
        category: 'maintenance',
      );
    }
  }

  /// Get all tips (for admin or browsing)
  Future<List<CyclingTip>> getAllTips() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('created_at', ascending: true);

    return (response as List).map((json) => CyclingTip.fromJson(json)).toList();
  }

  /// Get tips by category
  Future<List<CyclingTip>> getTipsByCategory(String category) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('category', category)
        .order('created_at', ascending: true);

    return (response as List).map((json) => CyclingTip.fromJson(json)).toList();
  }
}
