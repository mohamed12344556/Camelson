import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget {
  final int index;
  final String title;
  final bool isSelected;
  final Function(int) onTap;
  final double radius;

  const TabBarWidget({
    super.key,
    required this.index,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutQuart,
        tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        builder: (context, animation, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    Colors.grey[100]!,
                    const Color(0xFF2F98D7),
                    animation,
                  )!,
                  Color.lerp(
                    Colors.grey[100]!,
                    const Color(0xFF166EA2),
                    animation,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Color.lerp(
                        Colors.transparent,
                        const Color(0xFF2F98D7).withOpacity(0.3),
                        animation,
                      )!,
                  blurRadius: 10 * animation,
                  offset: Offset(0, 5 * animation),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  print('TabBarWidget - Tab "$title" (index: $index) tapped');
                  print('TabBarWidget - Currently selected: $isSelected');
                  print('TabBarWidget - About to call onTap($index)');
                  onTap(index);
                },
                borderRadius: BorderRadius.circular(radius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Color.lerp(
                          Colors.black54,
                          Colors.white,
                          animation,
                        ),
                        fontWeight: FontWeight.lerp(
                          FontWeight.normal,
                          FontWeight.bold,
                          animation,
                        ),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
