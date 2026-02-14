// import 'dart:math' as math;
// import 'dart:ui';

// import 'package:flutter/material.dart';

// import '../../data/models/subject_roadmap_model.dart';

// class ModernAnimatedRoadmap extends StatefulWidget {
//   final SubjectRoadmap roadmap;
//   final Function(LessonModel, ChapterModel) onLessonTap;
//   final Function(ChapterModel) onChapterTap;

//   const ModernAnimatedRoadmap({
//     super.key,
//     required this.roadmap,
//     required this.onLessonTap,
//     required this.onChapterTap,
//   });

//   @override
//   State<ModernAnimatedRoadmap> createState() => _ModernAnimatedRoadmapState();
// }

// class _ModernAnimatedRoadmapState extends State<ModernAnimatedRoadmap>
//     with TickerProviderStateMixin {
//   late List<AnimationController> _itemControllers;
//   late List<AnimationController> _lineControllers;
//   late List<AnimationController> _pulseControllers;
//   late List<Animation<double>> _itemAnimations;
//   late List<Animation<double>> _lineAnimations;
//   late List<Animation<double>> _pulseAnimations;
//   List<RoadmapItemData> _roadmapItems = [];

//   @override
//   void initState() {
//     super.initState();
//     _buildRoadmapData();
//     _initializeAnimations();
//     _startAnimations();
//   }

//   void _buildRoadmapData() {
//     _roadmapItems = [];

//     for (var chapter in widget.roadmap.chapters) {
//       // Add chapter header
//       _roadmapItems.add(
//         RoadmapItemData(
//           type: RoadmapItemType.chapter,
//           chapter: chapter,
//           lesson: null,
//         ),
//       );

//       // Add lessons
//       for (var lesson in chapter.lessons) {
//         _roadmapItems.add(
//           RoadmapItemData(
//             type: RoadmapItemType.lesson,
//             chapter: chapter,
//             lesson: lesson,
//           ),
//         );
//       }
//     }
//   }

//   void _initializeAnimations() {
//     _itemControllers = List.generate(
//       _roadmapItems.length,
//       (index) => AnimationController(
//         duration: Duration(milliseconds: 800 + (index * 100)),
//         vsync: this,
//       ),
//     );

//     _lineControllers = List.generate(
//       _roadmapItems.length - 1,
//       (index) => AnimationController(
//         duration: const Duration(milliseconds: 1000),
//         vsync: this,
//       ),
//     );

//     _pulseControllers = List.generate(
//       _roadmapItems.length,
//       (index) => AnimationController(
//         duration: const Duration(milliseconds: 2000),
//         vsync: this,
//       ),
//     );

//     _itemAnimations =
//         _itemControllers.map((controller) {
//           return CurvedAnimation(
//             parent: controller,
//             curve: Curves.fastOutSlowIn,
//           );
//         }).toList();

//     _lineAnimations =
//         _lineControllers.map((controller) {
//           return CurvedAnimation(parent: controller, curve: Curves.easeInOut);
//         }).toList();

//     _pulseAnimations =
//         _pulseControllers.map((controller) {
//           return Tween<double>(begin: 0.0, end: 1.0).animate(
//             CurvedAnimation(parent: controller, curve: Curves.easeInOut),
//           );
//         }).toList();
//   }

//   void _startAnimations() async {
//     for (int i = 0; i < _roadmapItems.length; i++) {
//       Future.delayed(Duration(milliseconds: i * 200), () {
//         if (mounted) {
//           _itemControllers[i].forward();

//           // Start pulse animation for current items
//           if (_roadmapItems[i].lesson?.isCurrent == true) {
//             _pulseControllers[i].repeat(reverse: true);
//           }
//         }
//       });

//       if (i < _roadmapItems.length - 1) {
//         Future.delayed(Duration(milliseconds: (i * 200) + 400), () {
//           if (mounted) {
//             _lineControllers[i].forward();
//           }
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     for (var controller in _itemControllers) {
//       controller.dispose();
//     }
//     for (var controller in _lineControllers) {
//       controller.dispose();
//     }
//     for (var controller in _pulseControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Colors.grey[50]!, Colors.grey[100]!, Colors.grey[200]!],
//         ),
//       ),
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: AnimatedBuilder(
//           animation: Listenable.merge([
//             ..._itemControllers,
//             ..._lineControllers,
//             ..._pulseControllers,
//           ]),
//           builder: (context, child) {
//             return CustomPaint(
//               painter: ModernRoadmapPainter(
//                 items: _roadmapItems,
//                 lineAnimations: _lineAnimations,
//                 itemWidth: 100,
//                 screenWidth: MediaQuery.of(context).size.width - 40,
//               ),
//               child: Column(children: _buildRoadmapWidgets()),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildRoadmapWidgets() {
//     List<Widget> widgets = [];

//     for (int i = 0; i < _roadmapItems.length; i++) {
//       final item = _roadmapItems[i];
//       final isLeft = i % 2 == 0;

//       widgets.add(
//         Container(
//           width: double.infinity,
//           margin: const EdgeInsets.only(bottom: 30),
//           child: Align(
//             alignment:
//                 item.type == RoadmapItemType.chapter
//                     ? Alignment.center
//                     : (isLeft ? Alignment.centerLeft : Alignment.centerRight),
//             child: Transform.translate(
//               offset: Offset(0, 50 * (1 - _itemAnimations[i].value)),
//               child: Transform.scale(
//                 scale: 0.3 + (0.7 * _itemAnimations[i].value),
//                 child: Opacity(
//                   opacity: _itemAnimations[i].value,
//                   child:
//                       item.type == RoadmapItemType.chapter
//                           ? _buildChapterItem(item.chapter!)
//                           : _buildLessonItem(item.lesson!, item.chapter!, i),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return widgets;
//   }

//   Widget _buildChapterItem(ChapterModel chapter) {
//     return GestureDetector(
//       onTap: () => widget.onChapterTap(chapter),
//       child: Container(
//         width: 300,
//         height: 100,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               chapter.chapterColor,
//               chapter.chapterColor.withOpacity(0.8),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: chapter.chapterColor.withOpacity(0.4),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//               spreadRadius: 0,
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             // Progress circle
//             Positioned(
//               right: 20,
//               top: 20,
//               child: SizedBox(
//                 width: 60,
//                 height: 60,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       value: chapter.progress / 100,
//                       strokeWidth: 4,
//                       backgroundColor: Colors.white.withOpacity(0.3),
//                       valueColor: const AlwaysStoppedAnimation<Color>(
//                         Colors.white,
//                       ),
//                     ),
//                     Text(
//                       '${chapter.progress.toInt()}%',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Chapter info
//             Positioned(
//               left: 20,
//               top: 20,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Chapter ${chapter.chapterNumber} - Lesson ${chapter.currentLesson}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     chapter.chapterName,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLessonItem(LessonModel lesson, ChapterModel chapter, int index) {
//     final Color primaryColor =
//         lesson.isCompleted
//             ? const Color(0xFF4CAF50)
//             : lesson.isCurrent
//             ? chapter.chapterColor
//             : Colors.grey[400]!;

//     return GestureDetector(
//       onTap: () => widget.onLessonTap(lesson, chapter),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Pulse animation for current lesson
//           if (lesson.isCurrent)
//             AnimatedBuilder(
//               animation: _pulseAnimations[index],
//               builder: (context, child) {
//                 return Container(
//                   width: 120 + (30 * _pulseAnimations[index].value),
//                   height: 120 + (30 * _pulseAnimations[index].value),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: chapter.chapterColor.withOpacity(
//                         0.3 * (1 - _pulseAnimations[index].value),
//                       ),
//                       width: 2,
//                     ),
//                   ),
//                 );
//               },
//             ),

//           // Main lesson container
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: primaryColor,
//                 width: lesson.isCompleted ? 4 : 3,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColor.withOpacity(0.3),
//                   blurRadius: 15,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Content
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(_getLessonIcon(lesson), size: 24, color: primaryColor),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Lesson ${lesson.lessonNumber}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor,
//                       ),
//                     ),
//                     Text(
//                       _getLessonTypeName(lesson.type),
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: primaryColor.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Completion checkmark
//                 if (lesson.isCompleted)
//                   Positioned(
//                     top: 5,
//                     right: 5,
//                     child: Container(
//                       width: 20,
//                       height: 20,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF4CAF50),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check,
//                         color: Colors.white,
//                         size: 14,
//                       ),
//                     ),
//                   ),

//                 // Lock icon
//                 if (lesson.isLocked)
//                   Positioned(
//                     top: 5,
//                     right: 5,
//                     child: Container(
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[600],
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.lock,
//                         color: Colors.white,
//                         size: 14,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getLessonIcon(LessonModel lesson) {
//     switch (lesson.type) {
//       case LessonType.video:
//         return Icons.play_circle_outline;
//       case LessonType.quiz:
//         return Icons.quiz_outlined;
//       case LessonType.assignment:
//         return Icons.assignment_outlined;
//       case LessonType.reading:
//         return Icons.menu_book_outlined;
//     }
//   }

//   String _getLessonTypeName(LessonType type) {
//     switch (type) {
//       case LessonType.video:
//         return 'Video';
//       case LessonType.quiz:
//         return 'Quiz';
//       case LessonType.assignment:
//         return 'Assignment';
//       case LessonType.reading:
//         return 'Reading';
//     }
//   }
// }

// class RoadmapItemData {
//   final RoadmapItemType type;
//   final ChapterModel? chapter;
//   final LessonModel? lesson;

//   RoadmapItemData({required this.type, this.chapter, this.lesson});
// }

// enum RoadmapItemType { chapter, lesson }

// class ModernRoadmapPainter extends CustomPainter {
//   final List<RoadmapItemData> items;
//   final List<Animation<double>> lineAnimations;
//   final double itemWidth;
//   final double screenWidth;

//   ModernRoadmapPainter({
//     required this.items,
//     required this.lineAnimations,
//     required this.itemWidth,
//     required this.screenWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint linePaint =
//         Paint()
//           ..color = const Color(0xFF42A5F5)
//           ..strokeWidth = 3
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round;

//     final Paint shadowPaint =
//         Paint()
//           ..color = const Color(0xFF42A5F5).withOpacity(0.3)
//           ..strokeWidth = 6
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round
//           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

//     double currentY = 80;

//     for (int i = 0; i < items.length - 1; i++) {
//       if (i >= lineAnimations.length) continue;

//       final currentItem = items[i];
//       final nextItem = items[i + 1];

//       double startX, endX;

//       if (currentItem.type == RoadmapItemType.chapter) {
//         startX = screenWidth / 2;
//       } else {
//         startX = (i % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       if (nextItem.type == RoadmapItemType.chapter) {
//         endX = screenWidth / 2;
//       } else {
//         endX = ((i + 1) % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       final startY = currentY + 50;
//       final endY = currentY + 130;

//       // Draw shadow
//       _drawAnimatedPath(
//         canvas,
//         Offset(startX, startY),
//         Offset(endX, endY),
//         shadowPaint,
//         lineAnimations[i].value,
//       );

//       // Draw main line
//       _drawAnimatedPath(
//         canvas,
//         Offset(startX, startY),
//         Offset(endX, endY),
//         linePaint,
//         lineAnimations[i].value,
//       );

//       currentY += 130;
//     }
//   }

//   void _drawAnimatedPath(
//     Canvas canvas,
//     Offset start,
//     Offset end,
//     Paint paint,
//     double animationValue,
//   ) {
//     final path = Path();
//     path.moveTo(start.dx, start.dy);

//     // Create smooth curve
//     final controlPoint = Offset(
//       start.dx + (end.dx - start.dx) * 0.5,
//       start.dy + (end.dy - start.dy) * 0.3,
//     );

//     path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

//     // Draw animated dashed line
//     final pathMetrics = path.computeMetrics();
//     for (PathMetric pathMetric in pathMetrics) {
//       final double totalLength = pathMetric.length;
//       final double animatedLength = totalLength * animationValue;

//       double distance = 0.0;
//       const double dashLength = 10.0;
//       const double gapLength = 5.0;

//       while (distance < animatedLength) {
//         final double remainingLength = animatedLength - distance;
//         final double currentDashLength = math.min(dashLength, remainingLength);

//         if (currentDashLength > 0) {
//           final Path dashPath = pathMetric.extractPath(
//             distance,
//             distance + currentDashLength,
//           );
//           canvas.drawPath(dashPath, paint);
//         }

//         distance += dashLength + gapLength;
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // بديل 1: Floating Progress Orbs - كرات تقدم متحركة
// class FloatingOrbsPainter extends CustomPainter {
//   final List<RoadmapItemData> items;
//   final List<Animation<double>> lineAnimations;
//   final double itemWidth;
//   final double screenWidth;

//   FloatingOrbsPainter({
//     required this.items,
//     required this.lineAnimations,
//     required this.itemWidth,
//     required this.screenWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     double currentY = 80;

//     for (int i = 0; i < items.length - 1; i++) {
//       if (i >= lineAnimations.length) continue;

//       final currentItem = items[i];
//       final nextItem = items[i + 1];

//       double startX, endX;

//       if (currentItem.type == RoadmapItemType.chapter) {
//         startX = screenWidth / 2;
//       } else {
//         startX = (i % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       if (nextItem.type == RoadmapItemType.chapter) {
//         endX = screenWidth / 2;
//       } else {
//         endX = ((i + 1) % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       final startY = currentY + 50;
//       final endY = currentY + 130;

//       // Draw floating orbs instead of lines
//       _drawFloatingOrbs(
//         canvas,
//         Offset(startX, startY),
//         Offset(endX, endY),
//         lineAnimations[i].value,
//       );

//       currentY += 130;
//     }
//   }

//   void _drawFloatingOrbs(
//     Canvas canvas,
//     Offset start,
//     Offset end,
//     double animationValue,
//   ) {
//     final orbCount = 5;
//     final orbSize = 8.0;

//     for (int i = 0; i < orbCount; i++) {
//       final progress = (i / (orbCount - 1)) * animationValue;
//       final orbPosition = Offset.lerp(start, end, progress)!;

//       // Create gradient effect
//       final paint =
//           Paint()
//             ..shader = RadialGradient(
//               colors: [
//                 Color(0xFF64B5F6).withOpacity(0.8),
//                 Color(0xFF1976D2).withOpacity(0.4),
//               ],
//             ).createShader(
//               Rect.fromCircle(center: orbPosition, radius: orbSize),
//             );

//       // Draw glowing orb
//       canvas.drawCircle(orbPosition, orbSize, paint);

//       // Add sparkle effect
//       final sparkle =
//           Paint()
//             ..color = Colors.white.withOpacity(0.6)
//             ..strokeWidth = 2
//             ..strokeCap = StrokeCap.round;

//       canvas.drawCircle(orbPosition, orbSize * 0.3, sparkle);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // بديل 2: Animated Progress Bars - شرائط تقدم متحركة
// class ProgressBarsPainter extends CustomPainter {
//   final List<RoadmapItemData> items;
//   final List<Animation<double>> lineAnimations;
//   final double itemWidth;
//   final double screenWidth;

//   ProgressBarsPainter({
//     required this.items,
//     required this.lineAnimations,
//     required this.itemWidth,
//     required this.screenWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     double currentY = 80;

//     for (int i = 0; i < items.length - 1; i++) {
//       if (i >= lineAnimations.length) continue;

//       final currentItem = items[i];
//       final nextItem = items[i + 1];

//       double startX, endX;

//       if (currentItem.type == RoadmapItemType.chapter) {
//         startX = screenWidth / 2;
//       } else {
//         startX = (i % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       if (nextItem.type == RoadmapItemType.chapter) {
//         endX = screenWidth / 2;
//       } else {
//         endX = ((i + 1) % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       final startY = currentY + 50;
//       final endY = currentY + 130;

//       // Draw animated progress bar
//       _drawProgressBar(
//         canvas,
//         Offset(startX, startY),
//         Offset(endX, endY),
//         lineAnimations[i].value,
//       );

//       currentY += 130;
//     }
//   }

//   void _drawProgressBar(
//     Canvas canvas,
//     Offset start,
//     Offset end,
//     double animationValue,
//   ) {
//     final barWidth = 6.0;
//     final progressLength = (end - start).distance * animationValue;

//     // Background bar
//     final backgroundPaint =
//         Paint()
//           ..color = Colors.grey.withOpacity(0.3)
//           ..strokeWidth = barWidth
//           ..strokeCap = StrokeCap.round;

//     canvas.drawLine(start, end, backgroundPaint);

//     // Progress bar with gradient
//     final progressPaint =
//         Paint()
//           ..shader = LinearGradient(
//             colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
//           ).createShader(Rect.fromPoints(start, end))
//           ..strokeWidth = barWidth
//           ..strokeCap = StrokeCap.round;

//     final progressEnd = Offset(
//       start.dx + (end.dx - start.dx) * animationValue,
//       start.dy + (end.dy - start.dy) * animationValue,
//     );

//     canvas.drawLine(start, progressEnd, progressPaint);

//     // Animated glow effect at the end
//     final glowPaint =
//         Paint()
//           ..color = Color(0xFF4CAF50).withOpacity(0.6)
//           ..strokeWidth = barWidth * 2
//           ..strokeCap = StrokeCap.round;

//     canvas.drawCircle(progressEnd, 8, glowPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // بديل 3: Particle Trail Effect - تأثير مسار الجسيمات
// class ParticleTrailPainter extends CustomPainter {
//   final List<RoadmapItemData> items;
//   final List<Animation<double>> lineAnimations;
//   final double itemWidth;
//   final double screenWidth;

//   ParticleTrailPainter({
//     required this.items,
//     required this.lineAnimations,
//     required this.itemWidth,
//     required this.screenWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     double currentY = 80;

//     for (int i = 0; i < items.length - 1; i++) {
//       if (i >= lineAnimations.length) continue;

//       final currentItem = items[i];
//       final nextItem = items[i + 1];

//       double startX, endX;

//       if (currentItem.type == RoadmapItemType.chapter) {
//         startX = screenWidth / 2;
//       } else {
//         startX = (i % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       if (nextItem.type == RoadmapItemType.chapter) {
//         endX = screenWidth / 2;
//       } else {
//         endX = ((i + 1) % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       final startY = currentY + 50;
//       final endY = currentY + 130;

//       // Draw particle trail
//       _drawParticleTrail(
//         canvas,
//         Offset(startX, startY),
//         Offset(endX, endY),
//         lineAnimations[i].value,
//       );

//       currentY += 130;
//     }
//   }

//   void _drawParticleTrail(
//     Canvas canvas,
//     Offset start,
//     Offset end,
//     double animationValue,
//   ) {
//     final particleCount = 20;
//     final trailLength = 0.3; // Length of the trail as a percentage

//     for (int i = 0; i < particleCount; i++) {
//       final baseProgress = (i / (particleCount - 1)) * animationValue;
//       final trailProgress = (baseProgress - trailLength).clamp(0.0, 1.0);

//       if (baseProgress > 0) {
//         final particlePosition = Offset.lerp(start, end, baseProgress)!;
//         final opacity = (1.0 - (baseProgress - trailProgress) / trailLength)
//             .clamp(0.0, 1.0);
//         final size = 3.0 + (opacity * 2.0);

//         final paint =
//             Paint()
//               ..color = Color(0xFF2196F3).withOpacity(opacity * 0.8)
//               ..style = PaintingStyle.fill;

//         canvas.drawCircle(particlePosition, size, paint);

//         // Add glow effect
//         final glowPaint =
//             Paint()
//               ..color = Color(0xFF64B5F6).withOpacity(opacity * 0.4)
//               ..style = PaintingStyle.fill;

//         canvas.drawCircle(particlePosition, size * 2, glowPaint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // بديل 4: Neumorphic Connecting Elements - عناصر ربط نيومورفيك
// class NeumorphicConnectorPainter extends CustomPainter {
//   final List<RoadmapItemData> items;
//   final List<Animation<double>> lineAnimations;
//   final double itemWidth;
//   final double screenWidth;

//   NeumorphicConnectorPainter({
//     required this.items,
//     required this.lineAnimations,
//     required this.itemWidth,
//     required this.screenWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     double currentY = 80;

//     for (int i = 0; i < items.length - 1; i++) {
//       if (i >= lineAnimations.length) continue;

//       final currentItem = items[i];
//       final nextItem = items[i + 1];

//       double startX, endX;

//       if (currentItem.type == RoadmapItemType.chapter) {
//         startX = screenWidth / 2;
//       } else {
//         startX = (i % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       if (nextItem.type == RoadmapItemType.chapter) {
//         endX = screenWidth / 2;
//       } else {
//         endX = ((i + 1) % 2 == 0) ? 70 : screenWidth - 70;
//       }

//       final startY = currentY + 50;
//       final endY = currentY + 130;

//       // Draw neumorphic connector
//       _drawNeumorphicConnector(
//         canvas,
//         Offset(startX, startY),
//         Offset(endX, endY),
//         lineAnimations[i].value,
//       );

//       currentY += 130;
//     }
//   }

//   void _drawNeumorphicConnector(
//     Canvas canvas,
//     Offset start,
//     Offset end,
//     double animationValue,
//   ) {
//     final connectorCount = 3;
//     final connectorSize = 15.0;

//     for (int i = 0; i < connectorCount; i++) {
//       final progress = (i / (connectorCount - 1)) * animationValue;
//       final connectorPosition = Offset.lerp(start, end, progress)!;

//       // Draw shadow (darker)
//       final shadowPaint =
//           Paint()
//             ..color = Colors.grey.withOpacity(0.3)
//             ..style = PaintingStyle.fill;

//       canvas.drawCircle(
//         connectorPosition + Offset(2, 2),
//         connectorSize,
//         shadowPaint,
//       );

//       // Draw highlight (lighter)
//       final highlightPaint =
//           Paint()
//             ..color = Colors.white.withOpacity(0.8)
//             ..style = PaintingStyle.fill;

//       canvas.drawCircle(
//         connectorPosition + Offset(-1, -1),
//         connectorSize,
//         highlightPaint,
//       );

//       // Draw main connector
//       final mainPaint =
//           Paint()
//             ..color = Color(0xFFF5F5F5)
//             ..style = PaintingStyle.fill;

//       canvas.drawCircle(connectorPosition, connectorSize, mainPaint);

//       // Add inner glow
//       final innerGlowPaint =
//           Paint()
//             ..color = Color(0xFF2196F3).withOpacity(0.3)
//             ..style = PaintingStyle.fill;

//       canvas.drawCircle(connectorPosition, connectorSize * 0.6, innerGlowPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
