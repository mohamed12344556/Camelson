import 'package:flutter/material.dart';

void main() {
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق التعلم الممتع',
      theme: ThemeData(
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: Colors.white,
        splashColor: Colors.transparent, // for bottom navigation bar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        fontFamily: 'Cairo',
      ),
      home: const HomePage(),
      locale: const Locale('en', 'EG'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> lessons = [
    {
      'id': 1,
      'title': 'مرحباً بك في المغامرة!',
      'status': 'completed',
      'xp': 50,
      'character': '🦁',
      'message': 'هيا نبدأ رحلة التعلم الممتعة!',
      'minigame': '🎮 لعبة المطابقة'
    },
    {
      'id': 2,
      'title': 'الدرس الأول: الحروف السحرية',
      'status': 'current',
      'xp': 100,
      'character': '🦊',
      'message': 'اكتشف أسرار الحروف معي!',
      'minigame': '🎲 تحدي الكلمات'
    },
  ];

  final List<Map<String, dynamic>> dailyChallenges = [
    {
      'id': 1,
      'title': 'أكمل 3 دروس',
      'reward': 50,
      'icon': '🎯',
      'progress': 2,
      'total': 3
    },
    {
      'id': 2,
      'title': 'اربح 100 نقطة',
      'reward': 30,
      'icon': '⭐',
      'progress': 75,
      'total': 100
    },
  ];

  final List<Map<String, dynamic>> achievements = [
    {
      'id': 1,
      'title': 'المتعلم النشيط',
      'description': '7 أيام متتالية',
      'icon': '🔥',
      'unlocked': true
    },
    {
      'id': 2,
      'title': 'عبقري الرياضيات',
      'description': 'حل 50 مسألة',
      'icon': '🧮',
      'unlocked': true
    },
    {
      'id': 3,
      'title': 'بطل اللغة',
      'description': 'إتقان القواعد',
      'icon': '📚',
      'unlocked': false
    },
  ];

  final List<Map<String, dynamic>> leaderboard = [
    {'id': 1, 'name': 'أحمد', 'points': 850, 'avatar': '👦'},
    {'id': 2, 'name': 'سارة', 'points': 820, 'avatar': '👧'},
    {'id': 3, 'name': 'محمد', 'points': 780, 'avatar': '👦'},
    {'id': 4, 'name': 'ابراهيم', 'points': 750, 'avatar': '👦'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _buildBody(),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildLessonsTab();
      case 1:
        return _buildChallengesTab();
      case 2:
        return _buildAchievementsTab();
      case 3:
        return _buildLeaderboardTab();
      default:
        return _buildLessonsTab();
    }
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'مغامرة التعلم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                _buildScoreChip(icon: '⭐', score: '350'),
                const SizedBox(width: 8),
                _buildScoreChip(icon: '🏆', score: '5'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip({required String icon, required String score}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 4),
          Text(
            score,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _buildLessonCard(lesson);
      },
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: lesson['status'] == 'current'
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Text(
              lesson['character'],
              style: const TextStyle(fontSize: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(lesson['message']),
                const SizedBox(height: 8),
                Text(
                  lesson['minigame'],
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('⭐ '),
                        Text('${lesson['xp']} نقطة'),
                      ],
                    ),
                    if (lesson['status'] == 'current')
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('ابدأ التحدي!'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailyChallenges.length,
      itemBuilder: (context, index) {
        final challenge = dailyChallenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    challenge['icon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    challenge['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('⭐ '),
                  Text('${challenge['reward']}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: challenge['progress'] / challenge['total'],
            backgroundColor: Colors.grey[200],
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 4),
          Text('${challenge['progress']}/${challenge['total']}'),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                achievement['icon'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                achievement['unlocked'] ? Icons.check_circle : Icons.lock,
                color: achievement['unlocked'] ? Colors.green : Colors.grey,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final player = leaderboard[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                index == 0 ? Border.all(color: Colors.yellow, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.yellow
                      : index == 1
                          ? Colors.grey[300]
                          : Colors.brown[300],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: index == 0 ? Colors.black : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                player['avatar'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  player['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  const Text('⭐ '),
                  Text(
                    '${player['points']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Text('📚', style: TextStyle(fontSize: 24)),
            label: 'دروسي',
          ),
          BottomNavigationBarItem(
            icon: Text('🎯', style: TextStyle(fontSize: 24)),
            label: 'التحديات',
          ),
          BottomNavigationBarItem(
            icon: Text('🏆', style: TextStyle(fontSize: 24)),
            label: 'الإنجازات',
          ),
          BottomNavigationBarItem(
            icon: Text('👑', style: TextStyle(fontSize: 24)),
            label: 'المتصدرون',
          ),
        ],
      ),
    );
  }
}