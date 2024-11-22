import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../models/song_model.dart';

class UserPlaySongScreen extends StatefulWidget {
  final SongModel song;

  const UserPlaySongScreen({Key? key, required this.song}) : super(key: key);

  @override
  State<UserPlaySongScreen> createState() => _UserPlaySongScreenState();
}

class _UserPlaySongScreenState extends State<UserPlaySongScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AudioPlayer _audioPlayer;
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _audioPlayer = AudioPlayer();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _initAudio();
  }

  Future<void> _initAudio() async {
    final audioUrl = convertDriveLinkToDirectLink(widget.song.audioUrl);
    await _audioPlayer.setUrl(audioUrl);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  String convertDriveLinkToDirectLink(String sharedLink) {
    final RegExp regExp = RegExp(r'\/d\/(.*)\/view');
    final match = regExp.firstMatch(sharedLink);

    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    return sharedLink;
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest3<Duration, Duration?, Duration, DurationState>(
        _audioPlayer.positionStream,
        _audioPlayer.durationStream,
        _audioPlayer.bufferedPositionStream,
        (position, duration, bufferedPosition) => DurationState(
          position: position,
          duration: duration ?? Duration.zero,
          bufferedPosition: bufferedPosition,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Thanh chỉ số trang (Smooth Page Indicator)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: SmoothPageIndicator(
              controller: _pageController, // Sử dụng PageController
              count: 2, // Số lượng trang trong PageView
              effect: WormEffect(
                // Chọn hiệu ứng hiển thị thanh chỉ số
                dotWidth: 18.0,
                dotHeight: 3.0,
                activeDotColor: Colors.white,
                dotColor: Colors.grey.withOpacity(0.5),
                spacing: 8.0,
              ),
            ),
          ),
          // PageView.builder
          Expanded(
            child: PageView.builder(
              controller: _pageController, // Sử dụng PageController
              physics: const BouncingScrollPhysics(),
              itemCount: 2, // Số lượng trang
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildMusicPlayer(); // Trang Player
                } else {
                  return _buildLyricsPage(); // Trang Lyrics
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 80,
        ),
        // Đĩa nhạc
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _rotationController,
              child: Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                        convertDriveLinkToDirectLink(widget.song.coverUrl)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 70,
        ),
        // Thông tin bài hát
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.list, size: 35, color: Colors.grey),
                    onPressed: () {
                      //
                    },
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.song.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.song.artist,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_outline,
                        size: 30, color: Colors.grey),
                    onPressed: () {
                      //
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 50,
        ),
        // Thanh tiến trình
        StreamBuilder<DurationState>(
          stream: _durationStateStream,
          builder: (context, snapshot) {
            final durationState = snapshot.data;
            final progress = durationState?.position ?? Duration.zero;
            final buffered = durationState?.bufferedPosition ?? Duration.zero;
            final total = durationState?.duration ?? Duration.zero;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ProgressBar(
                progress: progress,
                buffered: buffered,
                total: total,
                onSeek: (duration) {
                  _audioPlayer.seek(duration);
                },
                progressBarColor: const Color(0xFF005609),
                bufferedBarColor: Colors.grey,
                baseBarColor: Colors.grey.withOpacity(0.3),
                thumbColor: Colors.white,
                timeLabelTextStyle: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
        SizedBox(
          height: 20,
        ),
        // Nút điều khiển
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.shuffle, size: 30, color: Colors.grey),
              onPressed: () {
                //
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous,
                  size: 40, color: Color(0xFF005609)),
              onPressed: () {
                // Logic skip previous
              },
            ),
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing ?? false;

                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return const CircularProgressIndicator(color: Colors.white);
                }

                return GestureDetector(
                  onTap: () {
                    if (playing) {
                      _audioPlayer.pause();
                      _rotationController.stop();
                    } else {
                      _audioPlayer.play();
                      _rotationController.repeat();
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200), // Thời gian chuyển đổi
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation), // Hiệu ứng xoay nhẹ
                        child: child,
                      );
                    },
                    child: Container(
                      key: ValueKey<bool>(playing), // Để AnimatedSwitcher nhận diện trạng thái thay đổi
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF005609), // Màu viền
                          width: 4.0, // Độ dày viền
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: const Color(0xFF121212),
                        child: Icon(
                          playing ? Icons.pause : Icons.play_arrow, // Biểu tượng thay đổi
                          size: 40,
                          color: const Color(0xFF005609),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.skip_next,
                  size: 40, color: Color(0xFF005609)),
              onPressed: () {
                // Logic skip next
              },
            ),
            IconButton(
              icon: const Icon(Icons.repeat, size: 30, color: Colors.grey),
              onPressed: () {
                //
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLyricsPage() {
    return const Center(
      child: Text(
        "Lyrics will be displayed here",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}

class DurationState {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;

  DurationState({
    required this.position,
    required this.duration,
    required this.bufferedPosition,
  });
}
