import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:html' as html;

class HighScoreEntry {
  final String username;
  final int score;
  final DateTime date;
  
  HighScoreEntry({
    required this.username,
    required this.score,
    required this.date,
  });
  
  Map<String, dynamic> toJson() => {
    'username': username,
    'score': score,
    'date': date.toIso8601String(),
  };
  
  factory HighScoreEntry.fromJson(Map<String, dynamic> json) => HighScoreEntry(
    username: json['username'] as String,
    score: json['score'] as int,
    date: DateTime.parse(json['date'] as String),
  );
}

class HighScoreService {
  // Environment-based storage key to isolate dev/staging/production scores
  static String get _storageKey {
    final hostname = html.window.location.hostname;
    
    // Development environment (localhost)
    if (hostname.contains('localhost') || hostname.contains('127.0.0.1')) {
      return 'arcana_high_scores_dev';
    }
    // Staging environment (if you have one)
    else if (hostname.contains('staging')) {
      return 'arcana_high_scores_staging';
    }
    // Production environment
    else {
      return 'arcana_high_scores_prod';
    }
  }
  
  Future<List<HighScoreEntry>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      final scores = jsonList.map((json) => HighScoreEntry.fromJson(json as Map<String, dynamic>)).toList();
      scores.sort((a, b) => b.score.compareTo(a.score));
      return scores;
    } catch (e) {
      return [];
    }
  }
  
  Future<void> saveHighScore(String username, int score) async {
    if (username.isEmpty) return;
    
    final scores = await getHighScores();
    
    // Check if user already has a score
    final existingIndex = scores.indexWhere((e) => e.username == username);
    if (existingIndex != -1) {
      // Only update if new score is higher
      if (score > scores[existingIndex].score) {
        scores[existingIndex] = HighScoreEntry(
          username: username,
          score: score,
          date: DateTime.now(),
        );
      } else {
        return; // Don't save if score isn't better
      }
    } else {
      scores.add(HighScoreEntry(
        username: username,
        score: score,
        date: DateTime.now(),
      ));
    }
    
    // Keep top 100 scores
    scores.sort((a, b) => b.score.compareTo(a.score));
    final topScores = scores.take(100).toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(topScores.map((e) => e.toJson()).toList()));
  }
}
