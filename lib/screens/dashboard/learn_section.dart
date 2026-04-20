import 'package:flutter/material.dart';
import 'package:paper_gen/screens/dashboard/LearnScreen.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';

class LearnSection extends StatefulWidget {
  const LearnSection({super.key});

  @override
  State<LearnSection> createState() => _LearnSectionState();
}

class _LearnSectionState extends State<LearnSection> {
  YoutubePlayerController? _controller;
  String? _loadedVideoId;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _loadVideo(String videoId) {
    if (videoId.isEmpty || _loadedVideoId == videoId) return;
    _controller?.dispose();
    _loadedVideoId = videoId;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressData, QuestionData>(
      builder: (context, proData, qData, _) {
        final darkMode = proData.darkMode;

        // Use user's selected exam to show relevant videos
        final exam = qData.selectedExam ?? '';
        final videos =
            exam.isNotEmpty ? qData.videosForExam(exam) : qData.allLearnVideos;

        // Auto-load first video
        if (videos.isNotEmpty && _controller == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadVideo(videos[0]['videoId'] ?? '');
          });
        }

        final featured = videos.isNotEmpty ? videos[0] : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn',
                      style: TextStyle(
                        fontFamily: 'Copper',
                        color: darkMode
                            ? const Color(0xffFDFBF7)
                            : const Color(0xff0A0E27),
                        fontSize: 20.0,
                      ),
                    ),
                    if (exam.isNotEmpty)
                      Text(
                        exam,
                        style: const TextStyle(
                          color: Color(0xff26a69a),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LearnScreen()),
                  ),
                  child: const Text(
                    'See All →',
                    style: TextStyle(
                      color: Color(0xff26a69a),
                      fontFamily: 'Copper',
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Featured Player ─────────────────────────────────
            if (_controller != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: YoutubePlayer(
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: const Color(0xff26a69a),
                  progressColors: const ProgressBarColors(
                    playedColor: Color(0xff26a69a),
                    handleColor: Color(0xff26a69a),
                  ),
                ),
              )
            else
              // Skeleton loader while video initializes
              Container(
                height: 210,
                decoration: BoxDecoration(
                  color: darkMode
                      ? const Color(0xff1A1E37)
                      : const Color(0xffEFEDE8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff26a69a),
                    strokeWidth: 2,
                  ),
                ),
              ),

            if (featured != null) ...[
              const SizedBox(height: 8),
              Text(
                featured['title'] ?? '',
                style: TextStyle(
                  fontFamily: 'Copper',
                  color: darkMode
                      ? const Color(0xffFDFBF7)
                      : const Color(0xff0A0E27),
                  fontSize: 15.0,
                ),
              ),
              Text(
                featured['channelName'] ?? '',
                style:
                    const TextStyle(color: Color(0xff26a69a), fontSize: 12.0),
              ),
            ],

            const SizedBox(height: 12),

            // ── Horizontal Carousel ─────────────────────────────
            if (videos.length > 1)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final item = videos[index];
                    final videoId = item['videoId'] ?? '';
                    final isActive = _loadedVideoId == videoId;

                    return GestureDetector(
                      onTap: () => _loadVideo(videoId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 160,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xff26a69a)
                                : Colors.transparent,
                            width: 2,
                          ),
                          color: darkMode
                              ? const Color(0xff1A1E37)
                              : const Color(0xffEFEDE8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8)),
                              child: Image.network(
                                'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                                height: 70,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 70,
                                  color:
                                      const Color(0xff26a69a).withOpacity(0.2),
                                  child: const Icon(Icons.play_circle,
                                      color: Color(0xff26a69a)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                item['title'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: darkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
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
      },
    );
  }
}
