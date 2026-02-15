class ReviewModel {
  final String id;
  final String username;
  final String userImageUrl;
  final double rating;
  final String reviewText;
  final int likes;
  final String timeAgo;
  final DateTime datePosted;

  ReviewModel({
    required this.id,
    required this.username,
    this.userImageUrl = '',
    required this.rating,
    required this.reviewText,
    required this.likes,
    required this.timeAgo,
    required this.datePosted,
  });

  // Factory constructor to create a ReviewModel from JSON data
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      userImageUrl: json['userImageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewText: json['reviewText'] ?? '',
      likes: json['likes'] ?? 0,
      timeAgo: json['timeAgo'] ?? '',
      datePosted: json['datePosted'] != null
          ? DateTime.parse(json['datePosted'])
          : DateTime.now(),
    );
  }

  // Convert ReviewModel to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'reviewText': reviewText,
      'likes': likes,
      'timeAgo': timeAgo,
      'datePosted': datePosted.toIso8601String(),
    };
  }

  // Create a copy of ReviewModel with some fields updated
  ReviewModel copyWith({
    String? id,
    String? username,
    String? userImageUrl,
    double? rating,
    String? reviewText,
    int? likes,
    String? timeAgo,
    DateTime? datePosted,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      username: username ?? this.username,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      likes: likes ?? this.likes,
      timeAgo: timeAgo ?? this.timeAgo,
      datePosted: datePosted ?? this.datePosted,
    );
  }
}

// Medical course reviews data
final reviewsData = [
  ReviewModel(
    id: '1',
    username: 'Ahmed Mohamed',
    rating: 5.0,
    reviewText:
        'Excellent anatomy course! Prof. Ahmed Hassan explains complex concepts in a very clear and understandable way. The clinical correlations are particularly helpful for understanding real-world applications. Highly recommend for first-year medical students!',
    likes: 342,
    timeAgo: '1 Week Ago',
    datePosted: DateTime.now().subtract(const Duration(days: 7)),
  ),
  ReviewModel(
    id: '2',
    username: 'Sarah Ali',
    rating: 4.8,
    reviewText:
        'Great course with detailed explanations and high-quality diagrams. The skeletal and muscular system lectures were especially comprehensive. Would have loved more quiz questions for practice, but overall very satisfied with the content.',
    likes: 289,
    timeAgo: '2 Weeks Ago',
    datePosted: DateTime.now().subtract(const Duration(days: 14)),
  ),
  ReviewModel(
    id: '3',
    username: 'Youssef Ibrahim',
    rating: 4.9,
    reviewText:
        'Outstanding teaching style! The professor makes anatomy interesting and memorable. The lectures on the cardiovascular system and nervous system were incredibly detailed. Perfect preparation for medical school exams.',
    likes: 425,
    timeAgo: '3 Weeks Ago',
    datePosted: DateTime.now().subtract(const Duration(days: 21)),
  ),
  ReviewModel(
    id: '4',
    username: 'Layla Hassan',
    rating: 5.0,
    reviewText:
        'Best anatomy course I have taken! The explanations are crystal clear and the visual aids are excellent. Helped me tremendously in understanding complex anatomical structures. Worth every penny!',
    likes: 198,
    timeAgo: '1 Month Ago',
    datePosted: DateTime.now().subtract(const Duration(days: 30)),
  ),
];
