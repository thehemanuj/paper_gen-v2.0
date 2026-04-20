import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Player state
  YoutubePlayerController? _playerController;
  String? _activeVideoId;
  String? _activeTitle;
  String? _activeExam;

  // Courses tab state — default to user's exam if available
  String? _selectedExamKey;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Pre-select user's exam
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final proData = Provider.of<ProgressData>(context, listen: false);
      final qData = Provider.of<QuestionData>(context, listen: false);
      final userExam = qData.selectedExam ?? '';
      if (qData.availableSubjectsWithLinks.containsKey(userExam)) {
        setState(() => _selectedExamKey = userExam);
      } else if (qData.availableSubjectsWithLinks.isNotEmpty) {
        setState(() =>
            _selectedExamKey = qData.availableSubjectsWithLinks.keys.first);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _playerController?.dispose();
    super.dispose();
  }

  void _playVideo(String videoId, String title, String exam) {
    if (videoId.isEmpty || _activeVideoId == videoId) return;
    _playerController?.dispose();
    setState(() {
      _activeVideoId = videoId;
      _activeTitle = title;
      _activeExam = exam;
      _playerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressData, QuestionData>(
      builder: (context, proData, qData, _) {
        final darkMode = proData.darkMode;
        final bg = darkMode ? const Color(0xff0A0E27) : const Color(0xffFDFBF7);
        final cardBg =
            darkMode ? const Color(0xff1A1E37) : const Color(0xffEFEDE8);
        final textColor =
            darkMode ? const Color(0xffFDFBF7) : const Color(0xff0A0E27);

        // Flat video list for Videos tab
        final allVideos = qData.videosForExam(qData.selectedExam ?? "GATE-CSE");

        // Exam keys for Courses sidebar
        final examKeys = qData.availableSubjectsWithLinks.keys.toList();

        return Scaffold(
          backgroundColor: bg,
          body: Column(
            children: [
              // ── Top Banner ────────────────────────────────────
              Image.asset('images/papergen_border_up.png'),

              // ── App Bar Row ───────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios,
                          color: Color(0xff26a69a), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Learn',
                      style: TextStyle(
                        fontFamily: 'Copper',
                        color: textColor,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (qData.selectedExam != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xff26a69a).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xff26a69a), width: 1),
                        ),
                        child: Text(
                          qData.selectedExam!,
                          style: const TextStyle(
                            color: Color(0xff26a69a),
                            fontSize: 11,
                            fontFamily: 'Copper',
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Tab Bar ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xff26a69a),
                  labelColor: const Color(0xff26a69a),
                  unselectedLabelColor:
                      darkMode ? Colors.white38 : Colors.black38,
                  labelStyle:
                      const TextStyle(fontFamily: 'Copper', fontSize: 15),
                  tabs: const [
                    Tab(text: 'Videos'),
                    Tab(text: 'Courses'),
                  ],
                ),
              ),

              // ── Tab Content ───────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVideosTab(allVideos, darkMode, cardBg, textColor),
                    _buildCoursesTab(
                        qData, examKeys, darkMode, cardBg, textColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── VIDEOS TAB ──────────────────────────────────────────────────────────────

  Widget _buildVideosTab(List<Map<String, String>> videos, bool darkMode,
      Color cardBg, Color textColor) {
    return Column(
      children: [
        // Inline player when active
        if (_playerController != null) ...[
          const SizedBox(height: 4),
          YoutubePlayer(
            controller: _playerController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xff26a69a),
            progressColors: const ProgressBarColors(
              playedColor: Color(0xff26a69a),
              handleColor: Color(0xff26a69a),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activeTitle ?? '',
                        style: TextStyle(
                          fontFamily: 'Copper',
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _activeExam ?? '',
                        style: const TextStyle(
                            color: Color(0xff26a69a), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: darkMode ? Colors.white12 : Colors.black12, height: 1),
        ],

        // Video list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final item = videos[index];
              final videoId = item['videoId'] ?? '';
              final title = item['title'] ?? '';
              final exam = item['subject'] ?? '';
              final isPlaying = _activeVideoId == videoId;

              return GestureDetector(
                onTap: () => _playVideo(videoId, title, exam),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? const Color(0xff26a69a).withOpacity(0.12)
                        : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPlaying
                          ? const Color(0xff26a69a)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12)),
                        child: Stack(
                          children: [
                            Image.network(
                              'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                              width: 110,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 110,
                                height: 72,
                                color: const Color(0xff26a69a).withOpacity(0.2),
                                child: const Icon(Icons.play_circle,
                                    color: Color(0xff26a69a), size: 30),
                              ),
                            ),
                            // Play overlay
                            if (!isPlaying)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black26,
                                  child: const Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white70,
                                    size: 28,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      darkMode ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Exam badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xff26a69a).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  exam,
                                  style: const TextStyle(
                                    color: Color(0xff26a69a),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: const Color(0xff26a69a),
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── COURSES TAB ─────────────────────────────────────────────────────────────

  Widget _buildCoursesTab(QuestionData qData, List<String> examKeys,
      bool darkMode, Color cardBg, Color textColor) {
    if (examKeys.isEmpty) {
      return Center(
        child: Text('No courses available', style: TextStyle(color: textColor)),
      );
    }

    // Default to first key if nothing selected
    _selectedExamKey ??= examKeys.first;

    final subjects = qData.availableSubjectsWithLinks[_selectedExamKey] ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left Sidebar: Exam List ──────────────────────────
        Container(
          width: 115,
          color: darkMode ? const Color(0xff12162E) : const Color(0xffE8E6E1),
          child: ListView.builder(
            itemCount: examKeys.length,
            itemBuilder: (context, index) {
              final key = examKeys[index];
              final isSelected = _selectedExamKey == key;
              // Highlight user's own exam
              final isUserExam = key ==
                  Provider.of<QuestionData>(context, listen: false)
                      .selectedExam;

              return GestureDetector(
                onTap: () => setState(() => _selectedExamKey = key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xff26a69a).withOpacity(0.18)
                        : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSelected
                            ? const Color(0xff26a69a)
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          key,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xff26a69a)
                                : (darkMode ? Colors.white60 : Colors.black54),
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontFamily: 'Copper',
                          ),
                        ),
                      ),
                      // Star if it's user's selected exam
                      if (isUserExam)
                        const Icon(Icons.star,
                            color: Color(0xff26a69a), size: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Right: Subject / Video List ──────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam title + count
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedExamKey ?? '',
                      style: TextStyle(
                        fontFamily: 'Copper',
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${subjects.length} topics',
                      style: const TextStyle(
                        color: Color(0xff26a69a),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                  color: darkMode ? Colors.white12 : Colors.black12, height: 1),

              // Subject cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final s = subjects[index];
                    final subject = s['subject'] ?? '';
                    final url = s['url'] ?? '';
                    final videoId = qData.extractVideoId(url);
                    final isPlaying = _activeVideoId == videoId;

                    return GestureDetector(
                      onTap: () {
                        // Switch to Videos tab and play
                        _tabController.animateTo(0);
                        _playVideo(videoId, subject, _selectedExamKey ?? '');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? const Color(0xff26a69a).withOpacity(0.15)
                              : cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPlaying
                                ? const Color(0xff26a69a)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Index circle
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPlaying
                                    ? const Color(0xff26a69a)
                                    : (darkMode
                                        ? Colors.white10
                                        : Colors.black38),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isPlaying
                                        ? Colors.white
                                        : (darkMode
                                            ? Colors.white54
                                            : Colors.black45),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                                width: 60,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 40,
                                  color:
                                      const Color(0xff26a69a).withOpacity(0.2),
                                  child: const Icon(Icons.ondemand_video,
                                      color: Color(0xff26a69a), size: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Subject name
                            Expanded(
                              child: Text(
                                subject,
                                style: TextStyle(
                                  color:
                                      darkMode ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                  fontWeight: isPlaying
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),

                            Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle_outline,
                              color: const Color(0xff26a69a),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
