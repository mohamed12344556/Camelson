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

// example of usage:
final reviewsData = [
  ReviewModel(
    id: '1',
    username: 'Heather S. McMullen',
    rating: 4.2,
    reviewText:
        'The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse....,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les essesdfsfsdfdsfsfsfsfsdfsd,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse....,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les essesdfsfsdfdsfsfsfsfsdfsd,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse....,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les essesdfsfsdfdsfsfsfsfsdfsd,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse....,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les essesdfsfsdfdsfsfsfsfsdfsd,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse....,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les essesdfsfsdfdsfsfsfsfsdfsd,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse....,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les essesdfsfsdfdsfsfsfsfsdfsd,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse....,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...,The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les essesdfsfsdfdsfsfsfsfsdfsd',
    likes: 760,
    timeAgo: '2 Weeks Ago',
    datePosted: DateTime.now().subtract(const Duration(days: 14)),
  ),
  ReviewModel(
    id: '2',
    username: 'Heather S. McMullen',
    rating: 4.2,
    reviewText:
        'The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...',
    likes: 760,
    timeAgo: '2 Weeks Ago',
    datePosted: DateTime.now().subtract(const Duration(days: 14)),
  ),
  ReviewModel(
    id: '3',
    username: 'Heather S. McMullen',
    rating: 4.2,
    reviewText:
        'The Course is Very Good dolor sit amet, con sect tur adipiscing elit. Naturales divitas digit parab les esse...',
    likes: 760,
    timeAgo: '2 Weeks Ago',
    datePosted: DateTime.now().subtract(const Duration(days: 14)),
  ),
];
