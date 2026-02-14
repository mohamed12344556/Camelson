import 'package:flutter/material.dart';

import '../../../../core/themes/font_weight_helper.dart';

class CustomRectangleAvatarList extends StatelessWidget {
  final int itemCount;
  final double size;
  final double spacing;
  final String assetPrefix;

  const CustomRectangleAvatarList({
    super.key,
    required this.itemCount,
    this.size = 70.0,
    this.spacing = 16.0,
    required this.assetPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size + 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: Column(
              children: [
                Container(
                  width: size + 20,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: AssetImage(assetPrefix),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Name',
                  style: TextStyle(
                    color: Color(0xff202244),
                    fontSize: 13,
                    fontWeight: FontWeightHelper.semiBold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}