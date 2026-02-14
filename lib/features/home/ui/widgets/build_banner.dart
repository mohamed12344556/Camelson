// import 'dart:async';
// import 'package:flutter/material.dart';

// class BuildBanner extends StatefulWidget {
//   final List<Map<String, String>> bannersData;
//   const BuildBanner({
//     super.key,
//     required this.bannersData,
//   });

//   @override
//   State<BuildBanner> createState() => _BuildBannerState();
// }

// class _BuildBannerState extends State<BuildBanner> {
//   late PageController _boxController;
//   late List<List<Map<String, String>>> groupedData;
//   int _currentBox = 0;
//   int _currentIndicator = 0;
//   Timer? _timer;
//   double _progress = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     groupedData = _splitData(widget.bannersData, 4);
//     _boxController = PageController();
//     _startAutoScroll();
//   }

//   @override
//   void dispose() {
//     _boxController.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }

//   List<List<Map<String, String>>> _splitData(
//       List<Map<String, String>> data, int chunkSize) {
//     List<List<Map<String, String>>> chunks = [];
//     for (var i = 0; i < data.length; i += chunkSize) {
//       chunks.add(data.sublist(
//         i,
//         i + chunkSize > data.length ? data.length : i + chunkSize,
//       ));
//     }
//     return chunks;
//   }

//   void _startAutoScroll() {
//     _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       setState(() {
//         _progress += 0.025; // Progress per tick
//         if (_progress >= 1.0) {
//           _progress = 0.0;
//           if (_currentIndicator < groupedData[_currentBox].length - 1) {
//             _currentIndicator++;
//           } else {
//             _currentIndicator = 0;
//             _currentBox = (_currentBox + 1) % groupedData.length;
//             _boxController.animateToPage(
//               _currentBox,
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeInOut,
//             );
//           }
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 161,
//       child: PageView.builder(
//         controller: _boxController,
//         onPageChanged: (index) {
//           setState(() {
//             _currentBox = index;
//             _currentIndicator = 0;
//             _progress = 0.0;
//           });
//         },
//         itemCount: groupedData.length,
//         itemBuilder: (context, boxIndex) {
//           return Stack(
//             children: [
//               Column(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         final banner = groupedData[boxIndex][_currentIndicator];
//                         print(
//                             'Title: ${banner['title']}, Subtitle: ${banner['subtitle']}');
//                       },
//                       child: AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 500),
//                         transitionBuilder: (child, animation) {
//                           return FadeTransition(
//                             opacity: animation,
//                             child: child,
//                           );
//                         },
//                         child: _buildBannerItem(
//                           groupedData[boxIndex][_currentIndicator],
//                           key: ValueKey<int>(_currentIndicator),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 left: 16,
//                 right: 16,
//                 child: _buildProgressIndicators(groupedData[boxIndex].length),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBannerItem(Map<String, String> banner, {required Key key}) {
//     return Container(
//       key: key,
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         color: Color(0xff60C3FF),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     banner['title'] ?? '',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     banner['subtitle'] ?? '',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Image.asset(
//             banner['image'] ?? '',
//             width: 100,
//             height: 100,
//             fit: BoxFit.contain,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressIndicators(int itemCount) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(
//         itemCount,
//         (index) => Expanded(
//           child: Container(
//             padding: const EdgeInsets.only(left: 4, right: 4, top: 10),
//             child: LinearProgressIndicator(
//               borderRadius: BorderRadius.circular(8),
//               value: _currentIndicator == index ? _progress : 0.0,
//               backgroundColor: const Color.fromARGB(127, 255, 255, 255),
//               color: Color(0xff003553),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';

import 'package:flutter/material.dart';

class BuildBanner extends StatefulWidget {
  final List<Map<String, String>> bannersData;
  const BuildBanner({
    super.key,
    required this.bannersData,
  });

  @override
  State<BuildBanner> createState() => _BuildBannerState();
}

class _BuildBannerState extends State<BuildBanner> {
  late PageController _boxController;
  late List<List<Map<String, String>>> groupedData;
  int _currentBox = 0;
  int _currentIndicator = 0;
  Timer? _timer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    groupedData = _splitData(widget.bannersData, 4);
    _boxController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _boxController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  List<List<Map<String, String>>> _splitData(
      List<Map<String, String>> data, int chunkSize) {
    if (data.isEmpty) return [[]];
    
    List<List<Map<String, String>>> chunks = [];
    for (var i = 0; i < data.length; i += chunkSize) {
      chunks.add(data.sublist(
        i,
        i + chunkSize > data.length ? data.length : i + chunkSize,
      ));
    }
    return chunks;
  }

  void _startAutoScroll() {
    if (groupedData.isEmpty || groupedData[0].isEmpty) return;
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      
      setState(() {
        _progress += 0.025;
        
        if (_progress >= 1.0) {
          _progress = 0.0;
          
          if (_currentBox < groupedData.length && 
              _currentIndicator < groupedData[_currentBox].length - 1) {
            _currentIndicator++;
          } else {
            _currentIndicator = 0;
            _currentBox = (_currentBox + 1) % groupedData.length;
            _boxController.animateToPage(
              _currentBox,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (groupedData.isEmpty || groupedData[0].isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 161,
      child: PageView.builder(
        controller: _boxController,
        onPageChanged: (index) {
          setState(() {
            _currentBox = index;
            _currentIndicator = 0;
            _progress = 0.0;
          });
        },
        itemCount: groupedData.length,
        itemBuilder: (context, boxIndex) {
          // التحقق من صحة المؤشرات
          if (boxIndex >= groupedData.length || 
              _currentIndicator >= groupedData[boxIndex].length) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final banner = groupedData[boxIndex][_currentIndicator];
                        print(
                            'Title: ${banner['title']}, Subtitle: ${banner['subtitle']}');
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _buildBannerItem(
                          groupedData[boxIndex][_currentIndicator],
                          key: ValueKey<int>(_currentIndicator),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                child: _buildProgressIndicators(groupedData[boxIndex].length),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBannerItem(Map<String, String> banner, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xff60C3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner['subtitle'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (banner['image'] != null && banner['image']!.isNotEmpty)
            Image.asset(
              banner['image']!,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 10),
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(8),
              value: _currentIndicator == index ? _progress : 0.0,
              backgroundColor: const Color.fromARGB(127, 255, 255, 255),
              color: const Color(0xff003553),
            ),
          ),
        ),
      ),
    );
  }
}