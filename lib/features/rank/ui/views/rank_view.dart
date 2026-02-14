import 'dart:developer';

import '../widgets/build_rank_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../data/models/user_rank_model.dart';
import '../widgets/custom_paint_rectangle.dart';

class RankView extends StatefulWidget {
  const RankView({super.key});

  @override
  State<RankView> createState() => _RankViewState();
}

class _RankViewState extends State<RankView> {
  int _currentTabIndex = 0;

  final List<UserRankModel> weeklyRanks = [
    UserRankModel(
      rank: 1,
      name: 'Davis Curtis',
      xp: 2569,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'gold',
    ),
    UserRankModel(
      rank: 2,
      name: 'Alena Donin',
      xp: 1469,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'silver',
    ),
    UserRankModel(
      rank: 3,
      name: 'Craig Gouse',
      xp: 1053,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'bronze',
    ),
    UserRankModel(
      rank: 4,
      name: 'Madelyn Dias',
      xp: 590,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'none',
    ),
    UserRankModel(
      rank: 5,
      name: 'Zain Vaccaro',
      xp: 448,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'none',
    ),
    UserRankModel(
      rank: 6,
      name: 'Skylar Geidt',
      xp: 448,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'none',
    ),
    UserRankModel(
      rank: 7,
      name: 'Justin Bator',
      xp: 335,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'none',
    ),
  ];

  final List<UserRankModel> allTimeRanks = [
    UserRankModel(
      rank: 1,
      name: 'Ahmed Mohamed',
      xp: 15690,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'gold',
    ),
    UserRankModel(
      rank: 2,
      name: 'Sara Ali',
      xp: 12450,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'silver',
    ),
    UserRankModel(
      rank: 3,
      name: 'Omar Hassan',
      xp: 9876,
      userAvatarUrl: 'assets/images/profile.png',
      badgeType: 'bronze',
    ),
  ];

  List<UserRankModel> get currentRanks {
    return _currentTabIndex == 0 ? weeklyRanks : allTimeRanks;
  }

  void _updateTabIndex(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  TabBarWidget(
                    index: 0,
                    title: 'Weekly',
                    isSelected: _currentTabIndex == 0,
                    onTap: _updateTabIndex,
                    radius: 16,
                  ),
                  const SizedBox(width: 16),
                  TabBarWidget(
                    index: 1,
                    title: 'All Time',
                    isSelected: _currentTabIndex == 1,
                    onTap: _updateTabIndex,
                    radius: 16,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Custom Paint Background with ListView and Dot Shape
            Expanded(
              child: Stack(
                children: [
                  // Custom Paint Background
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CustomPaint(
                        size: Size(
                          MediaQuery.of(context).size.width - 32.w,
                          MediaQuery.of(context).size.height,
                        ),
                        painter: RPSCustomPainter(),
                      ),
                    ),
                  ),

                  // Dot Shape
                  Positioned(
                    top: 5.h,
                    right: 209.7.w,
                    child: Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff003C60),
                      ),
                    ),
                  ),

                  // ListView Content
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: currentRanks.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => log(currentRanks[index].name),
                            child: BuildRankCard(user: currentRanks[index]),
                          );
                        },
                      ),
                    ),
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
