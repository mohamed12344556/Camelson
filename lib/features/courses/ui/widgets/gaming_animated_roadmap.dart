import 'package:camelson/core/constants/roadmap_constants.dart';
import 'package:camelson/features/courses/ui/widgets/roadmap_widgets.dart';
import 'package:flutter/material.dart';

import '../../data/models/roadmap_data_models.dart';
import '../../data/models/subject_roadmap_model.dart';
import '../painters/floating_orbs_painter.dart';
import '../painters/timeline_painter.dart';

class GamingAnimatedRoadmap extends StatefulWidget {
  final SubjectRoadmap roadmap;
  final Function(LessonModel, ChapterModel) onLessonTap;
  final Function(ChapterModel) onChapterTap;
  final RoadmapAnimationStyle? initialStyle;

  const GamingAnimatedRoadmap({
    super.key,
    required this.roadmap,
    required this.onLessonTap,
    required this.onChapterTap,
    this.initialStyle,
  });

  @override
  State<GamingAnimatedRoadmap> createState() => _GamingAnimatedRoadmapState();
}

class _GamingAnimatedRoadmapState extends State<GamingAnimatedRoadmap>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late List<AnimationController> _itemControllers;
  late List<AnimationController> _connectionControllers;
  late List<AnimationController> _pulseControllers;
  late List<AnimationController> _flowControllers;
  late List<AnimationController> _timelineControllers;
  late List<AnimationController> _orbControllers;

  late List<Animation<double>> _itemAnimations;
  late List<Animation<double>> _connectionAnimations;
  late List<Animation<double>> _pulseAnimations;
  late List<Animation<double>> _flowAnimations;
  late List<Animation<double>> _timelineAnimations;
  late List<Animation<double>> _orbAnimations;

  List<RoadmapItemData> _roadmapItems = [];
  List<GlobalKey> _itemKeys = [];
  double _scrollOffset = 0.0; // إضافة متغير الـ scroll offset

  // Animation Style Selection - Default to timeline
  RoadmapAnimationStyle _currentStyle = RoadmapAnimationStyle.timeline;

  @override
  void initState() {
    super.initState();
    if (widget.initialStyle != null) {
      _currentStyle = widget.initialStyle!;
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _buildRoadmapData();
    _initializeAnimations();
    _startAnimations();
  }

  void _buildRoadmapData() {
    _roadmapItems = [];
    _itemKeys = [];

    for (var chapter in widget.roadmap.chapters) {
      _roadmapItems.add(
        RoadmapItemData(
          type: RoadmapItemType.chapter,
          chapter: chapter,
          lesson: null,
        ),
      );
      _itemKeys.add(GlobalKey());

      for (var lesson in chapter.lessons) {
        _roadmapItems.add(
          RoadmapItemData(
            type: RoadmapItemType.lesson,
            chapter: chapter,
            lesson: lesson,
          ),
        );
        _itemKeys.add(GlobalKey());
      }
    }
  }

  void _initializeAnimations() {
    final itemCount = _roadmapItems.length;
    final connectionCount = itemCount > 1 ? itemCount - 1 : 0;

    // Item animations
    _itemControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 100)),
        vsync: this,
      ),
    );

    // Connection animations for all styles
    _connectionControllers = List.generate(
      connectionCount,
      (index) => AnimationController(
        duration: AnimationDurations.connectionAnimation,
        vsync: this,
      ),
    );

    _pulseControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        duration: AnimationDurations.pulseAnimation,
        vsync: this,
      ),
    );

    _flowControllers = List.generate(
      connectionCount,
      (index) => AnimationController(
        duration: AnimationDurations.flowAnimation,
        vsync: this,
      ),
    );

    _timelineControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500 + (index * 150)),
        vsync: this,
      ),
    );

    _orbControllers = List.generate(
      connectionCount,
      (index) => AnimationController(
        duration: AnimationDurations.orbAnimation,
        vsync: this,
      ),
    );

    // Create animations
    _itemAnimations = _itemControllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.elasticOut);
    }).toList();

    _connectionAnimations = _connectionControllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
    }).toList();

    _pulseAnimations = _pulseControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _flowAnimations = _flowControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    }).toList();

    _timelineAnimations = _timelineControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    _orbAnimations = _orbControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    }).toList();
  }

  void _startAnimations() async {
    for (int i = 0; i < _roadmapItems.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _itemControllers[i].forward();
          _timelineControllers[i].forward();

          // Start special animations for current items
          if (_roadmapItems[i].lesson?.isCurrent == true) {
            _pulseControllers[i].repeat(reverse: true);
          }
        }
      });
    }

    // Start connection animations
    for (int i = 0; i < _connectionControllers.length; i++) {
      Future.delayed(Duration(milliseconds: (i * 200) + 1000), () {
        if (mounted) {
          _connectionControllers[i].forward();
          _flowControllers[i].repeat();
          _orbControllers[i].repeat();
        }
      });
    }
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });

    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    for (int i = 0; i < _itemKeys.length; i++) {
      final RenderBox? renderBox =
          _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final itemTop = position.dy;
        final screenCenter = MediaQuery.of(context).size.height / 2;

        if ((itemTop - screenCenter).abs() < 200) {
          final connectionIndex = i.clamp(0, _connectionControllers.length - 1);
          if (!_connectionControllers[connectionIndex].isAnimating) {
            _connectionControllers[connectionIndex].forward();
          }
        }
      }
    }
  }

  @override
  void didUpdateWidget(GamingAnimatedRoadmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStyle != null && widget.initialStyle != _currentStyle) {
      setState(() {
        _currentStyle = widget.initialStyle!;
      });
      _resetAndRestartAnimations();
    }
  }

  void changeAnimationStyle(RoadmapAnimationStyle newStyle) {
    setState(() {
      _currentStyle = newStyle;
    });

    // Restart animations for new style
    _resetAndRestartAnimations();
  }

  void _resetAndRestartAnimations() {
    // Reset all controllers
    for (var controller in _connectionControllers) controller.reset();
    for (var controller in _flowControllers) controller.reset();
    for (var controller in _orbControllers) controller.reset();

    // Restart with slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _startAnimations();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    // Dispose all controllers
    for (var controller in _itemControllers) controller.dispose();
    for (var controller in _connectionControllers) controller.dispose();
    for (var controller in _pulseControllers) controller.dispose();
    for (var controller in _flowControllers) controller.dispose();
    for (var controller in _timelineControllers) controller.dispose();
    for (var controller in _orbControllers) controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoadmapStyleConfig.getColors(_currentStyle);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(gradient: colors.background),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(
              RoadmapSizes.isDesktop(context)
                  ? 40
                  : RoadmapSizes.isTablet(context)
                  ? 30
                  : 20,
            ),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                ..._itemControllers,
                ..._connectionControllers,
                ..._pulseControllers,
                ..._flowControllers,
                ..._timelineControllers,
                ..._orbControllers,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: _getCurrentPainter(constraints),
                  child: Column(children: _buildResponsiveRoadmapWidgets()),
                );
              },
            ),
          ),
        );
      },
    );
  }

  CustomPainter _getCurrentPainter(BoxConstraints constraints) {
    final screenWidth =
        constraints.maxWidth -
        (RoadmapSizes.isDesktop(context)
            ? 80
            : RoadmapSizes.isTablet(context)
            ? 60
            : 40);

    switch (_currentStyle) {
      case RoadmapAnimationStyle.floatingOrbs:
        return FloatingOrbsPainter(
          items: _roadmapItems,
          connectionAnimations: _connectionAnimations,
          orbAnimations: _orbAnimations,
          itemSize: RoadmapSizes.getItemSize(context),
          chapterWidth: RoadmapSizes.getChapterWidth(context),
          chapterHeight: RoadmapSizes.getChapterHeight(context),
          screenWidth: screenWidth,
          spacing: RoadmapSizes.getSpacing(context),
          // scrollOffset: _scrollOffset, // تمرير الـ scroll offset
        );
      case RoadmapAnimationStyle.timeline:
        return TimelineProgressPainter(
          items: _roadmapItems,
          timelineAnimations: _timelineAnimations,
          connectionAnimations: _connectionAnimations,
          itemSize: RoadmapSizes.getItemSize(context),
          chapterWidth: RoadmapSizes.getChapterWidth(context),
          chapterHeight: RoadmapSizes.getChapterHeight(context),
          screenWidth: screenWidth,
          spacing: RoadmapSizes.getSpacing(context),
          scrollOffset: _scrollOffset, // تمرير الـ scroll offset
        );
    }
  }

  List<Widget> _buildResponsiveRoadmapWidgets() {
    List<Widget> widgets = [];
    final spacing = RoadmapSizes.getSpacing(context);

    for (int i = 0; i < _roadmapItems.length; i++) {
      final item = _roadmapItems[i];
      final isLeft = i % 2 == 0;
      final animationValue = _itemAnimations[i].value.clamp(0.0, 1.0);

      widgets.add(
        Container(
          key: _itemKeys[i],
          width: double.infinity,
          margin: EdgeInsets.only(bottom: spacing),
          child: Align(
            alignment: item.type == RoadmapItemType.chapter
                ? Alignment.center
                : (isLeft ? Alignment.centerLeft : Alignment.centerRight),
            child: item.type == RoadmapItemType.chapter
                ? RoadmapChapterWidget(
                    chapter: item.chapter!,
                    index: i,
                    style: _currentStyle,
                    animationValue: animationValue,
                    onTap: () => widget.onChapterTap(item.chapter!),
                  )
                : RoadmapLessonWidget(
                    lesson: item.lesson!,
                    chapter: item.chapter!,
                    index: i,
                    style: _currentStyle,
                    animationValue: animationValue,
                    pulseAnimation: i < _pulseAnimations.length
                        ? _pulseAnimations[i]
                        : null,
                    onTap: widget.onLessonTap,
                  ),
          ),
        ),
      );
    }

    return widgets;
  }
}
