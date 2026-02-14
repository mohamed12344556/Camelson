import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_app_bar.dart';

class CourseContentsView extends StatefulWidget {
  const CourseContentsView({super.key});

  @override
  State<CourseContentsView> createState() => _CourseContentsViewState();
}

class _CourseContentsViewState extends State<CourseContentsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoPlayerController _videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  final CustomVideoPlayerSettings _customVideoPlayerSettings =
      CustomVideoPlayerSettings(
    showSeekButtons: true,
    alwaysShowThumbnailOnVideoPaused: true,
    controlBarDecoration: const BoxDecoration(
      color: Colors.transparent,
    ),
    customAspectRatio: 16 / 9,
    customVideoPlayerProgressBarSettings: CustomVideoPlayerProgressBarSettings(
      backgroundColor: Color(0xff494b4c),
      bufferedColor: Color(0xffbdbdbd).withValues(alpha: 0.5),
      progressBarBorderRadius: 4,
      progressBarHeight: 8,
      progressColor: Color(0xff167F71),
    ),
    durationPlayedTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    durationRemainingTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    playbackButtonTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    placeholderWidget: Center(child: CircularProgressIndicator.adaptive()),
    pauseButton: Icon(
      Icons.pause,
      size: 25,
      color: Colors.white,
    ),
    playButton: Icon(
      Icons.play_arrow,
      size: 25,
      color: Colors.white,
    ),
    thumbnailWidget: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/arabic.png'),
        ),
      ),
    ),
    settingsButton: Icon(
      Icons.settings,
      size: 25,
      color: Colors.white,
    ),
  );

  // late CachedVideoPlayerController _videoPlayerController,
  //     _videoPlayerController2,
  //     _videoPlayerController3; //! need Package cached_video_player

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
    );

    _videoPlayerController.initialize().then((_) {
      setState(() {}); // Update the UI after initialization
    });
    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: _videoPlayerController,
      customVideoPlayerSettings: _customVideoPlayerSettings,
    );

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      animationDuration: Duration(milliseconds: 300),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Course Content'),
        body: SafeArea(
          child: Column(
            children: [
              //? Video Player Section
              Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height * 0.25,
                child: CustomVideoPlayer(
                  customVideoPlayerController: _customVideoPlayerController,
                ),
              ),

              //? Tabs
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F9FF),
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    dividerColor: Colors.transparent,
                    unselectedLabelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorWeight: 1,
                    physics: BouncingScrollPhysics(),
                    tabs: [
                      Tab(text: 'Lessons'),
                      Tab(text: 'Materials'),
                      Tab(text: 'Notes'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
              ),

              //? Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(child: Text('Lessons Content')),
                    _buildMaterialsTab(),
                    Center(child: Text('Notes Content')),
                    Center(child: Text('Reviews Content')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  radius: 30,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reading Material',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'PDF Document',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  child: Text('View'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
