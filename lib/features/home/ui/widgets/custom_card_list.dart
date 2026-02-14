import 'package:flutter/material.dart';

import '../../../../core/themes/font_weight_helper.dart';

class CustomCardList extends StatelessWidget {
  final int itemCount;
  final double cardWidth;
  final double cardHeight;
  final double spacing;
  final String liveText;
  final List<Map<String, dynamic>> streamingData; // Added parameter

  const CustomCardList({
    super.key,
    required this.itemCount,
    required this.streamingData, // Required parameter
    this.cardWidth = 150.0,
    this.cardHeight = 200.0,
    this.spacing = 16.0,
    this.liveText = 'LIVE',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Get data for current item (cycle through provided data)
          final data = streamingData[index % streamingData.length];

          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to course details or streaming page
                debugPrint('Tapped on: ${data['title']}');
              },
              child: Stack(
                children: [
                  //? Card
                  Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(data['image']),
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.85),
                      ),
                    ),
                  ),
                  //? Live Text (only show if isLive is true)
                  if (data['isLive'])
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff0075BB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          liveText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeightHelper.extraBold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  //? Description
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.only(
                        right: 12,
                        left: 10,
                        bottom: 8,
                      ),
                      width: cardWidth,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0x00000000), Color(0xB3000000)],
                          stops: [0.0, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Instructor and duration row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundImage: AssetImage(data['avatar']),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data['instructor'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeightHelper.regular,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                data['duration'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeightHelper.regular,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Course title
                          Text(
                            data['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: -0.5,
                              fontWeight: FontWeightHelper.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
