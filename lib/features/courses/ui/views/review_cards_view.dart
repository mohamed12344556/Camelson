import 'package:flutter/material.dart';

import '../../data/models/review_model.dart';
import '../widgets/review_card.dart';

class ReviewCardsView extends StatefulWidget {
  const ReviewCardsView({super.key});

  @override
  State<ReviewCardsView> createState() => _ReviewCardsViewState();
}

class _ReviewCardsViewState extends State<ReviewCardsView> {
  // Sample data - in a real app, this would come from an API or database
  final List<ReviewModel> reviews = reviewsData;

  // Method to handle liking a review
  void likeReview(String reviewId) {
    setState(() {
      final index = reviews.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        reviews[index] = reviews[index].copyWith(
          likes: reviews[index].likes + 1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ReviewCard(
              review: review,
              onLike: () => likeReview(review.id),
            ),
          );
        },
      ),
    );
  }
}
