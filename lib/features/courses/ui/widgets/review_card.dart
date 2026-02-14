import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/review_model.dart';

class ReviewCard extends StatefulWidget {
  final ReviewModel review;
  final VoidCallback onLike;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onLike,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile picture
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: widget.review.userImageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.review.userImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.person, color: Colors.white),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.person, color: Colors.white),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //? Username and rating
                  Row(
                    children: [
                      // Username
                      Expanded(
                        flex: 3,
                        child: Text(
                          widget.review.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: Color(0xff202244),
                          ),
                        ),
                      ),
                      Spacer(),
                      // Rating badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xffE8F1FF),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.review.rating.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  //? Review text with Read More button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.review.reviewText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff545454),
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: _isExpanded ? null : 3,
                        overflow: _isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      if (widget.review.reviewText.length > 50)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              _isExpanded ? "عرض أقل" : "قراءة المزيد",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  //? Likes and time
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onLike,
                        child: Icon(Icons.favorite,
                            color: Colors.red.shade400, size: 20),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.review.likes.toString(),
                        style: const TextStyle(
                          color: Color(0xff202244),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.review.timeAgo,
                        style: const TextStyle(
                          color: Color(0xff202244),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
