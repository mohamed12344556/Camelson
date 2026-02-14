import 'package:flutter/material.dart';

import '../../../home/ui/widgets/build_row_of_text_and_text_button.dart';
import '../views/review_cards_view.dart';

class ReviewsCourseSection extends StatelessWidget {
  const ReviewsCourseSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(color: Colors.grey[300], thickness: 1),
          BuildRowOfTextAndTextButton(
            onPressed: () {},
            text: 'Reviews',
            seeAllColor: Color(0xffA0A4AB),
          ),
          ReviewCardsView(),
        ],
      ),
    );
  }
}