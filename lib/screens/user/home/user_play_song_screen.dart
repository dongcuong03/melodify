import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../models/song_model.dart';
import 'package:lrc/lrc.dart';
import 'dart:convert'; // Để xử lý nội dung tải về
import 'package:http/http.dart' as http;

class UserPlaySongScreen extends StatefulWidget {
  final SongModel song;
  final List<SongModel> listSongs;

  const UserPlaySongScreen(
      {Key? key, required this.song, required this.listSongs})
      : super(key: key);

  @override
  State<UserPlaySongScreen> createState() => _UserPlaySongScreenState();
}

class _UserPlaySongScreenState extends State<UserPlaySongScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AudioPlayer _audioPlayer;
  late final AnimationController _rotationController;
  late ScrollController _scrollController;
  bool _isUserScrolling = false;
  late SongModel currentSong;
  late List<SongModel> songs;
  bool _isLoadingLyrics = false;
  bool isShuffle = false;
  bool isRepeat = false;

  // Khai báo danh sách lyrics
  List<LyricsLine> _lyrics = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    currentSong = widget.song;
    songs = widget.listSongs;
    _audioPlayer = AudioPlayer();

    _scrollController = ScrollController();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    // Lắng nghe sự kiện khi bài hát kết thúc và gọi playNextSong()
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // Khi bài hát kết thúc, phát bài hát tiếp theo
        playNextSong();
      }
    });

    _initAudio();
    // Tải lyrics
    if (currentSong.lyricUrl != null) {
      _loadLyrics(currentSong.lyricUrl!);
    }
  }

  Future<void> _initAudio() async {
    final audioUrl = convertDriveLinkToDirectLink(currentSong.audioUrl);
    await _audioPlayer.setUrl(audioUrl);
  }

  void playNextSong() async {
    if (isRepeat) {
      // Nếu chế độ Repeat, phát lại bài hát hiện tại
      final audioUrl = convertDriveLinkToDirectLink(currentSong.audioUrl);
      await _audioPlayer.setUrl(audioUrl);
      _audioPlayer.play();
    } else if (isShuffle) {
      // Nếu chế độ Shuffle, chọn bài ngẫu nhiên
      final randomIndex = (songs..shuffle()).first;
      setState(() {
        _isLoadingLyrics = true;
        currentSong = randomIndex;
      });

      // Cập nhật audio và tải lyrics cùng lúc
      final audioUrl = convertDriveLinkToDirectLink(currentSong.audioUrl);
      Future<void> audioFuture = _audioPlayer.setUrl(audioUrl);

      Future<void> lyricsFuture = Future<void>.value();
      if (currentSong.lyricUrl != null) {
        lyricsFuture = _loadLyrics(currentSong.lyricUrl!);
      }

      // Đợi cả hai tác vụ (audio và lyrics) xong
      await Future.wait([audioFuture, lyricsFuture]);

      setState(() {
        _isLoadingLyrics = false; // Tắt trạng thái tải lyrics
      });
      _audioPlayer.play();
    } else {
      // Chế độ bình thường, phát bài tiếp theo
      final currentIndex = songs.indexOf(currentSong);
      if (currentIndex < songs.length - 1) {
        setState(() {
          _isLoadingLyrics = true; // Đánh dấu đang tải lyrics
        });

        // Chọn bài hát tiếp theo
        currentSong = songs[currentIndex + 1];

        // Cập nhật audio và tải lyrics cùng lúc
        final audioUrl = convertDriveLinkToDirectLink(currentSong.audioUrl);
        Future<void> audioFuture = _audioPlayer.setUrl(audioUrl);

        Future<void> lyricsFuture = Future<void>.value();
        if (currentSong.lyricUrl != null) {
          lyricsFuture = _loadLyrics(currentSong.lyricUrl!);
        }

        // Đợi cả hai tác vụ (audio và lyrics) xong
        await Future.wait([audioFuture, lyricsFuture]);

        setState(() {
          _isLoadingLyrics = false; // Tắt trạng thái tải lyrics
        });
        _audioPlayer.play();
      }
    }
  }



  void playPreviousSong() async {
    final currentIndex = songs.indexOf(currentSong);
    if (currentIndex > 0) {
      setState(() {
        _isLoadingLyrics = true; // Đánh dấu đang tải lyrics
      });

      // Chọn bài hát trước
      currentSong = songs[currentIndex - 1];

      // Cập nhật audio và tải lyrics cùng lúc
      final audioUrl = convertDriveLinkToDirectLink(currentSong.audioUrl);
      Future<void> audioFuture = _audioPlayer.setUrl(audioUrl);

      Future<void> lyricsFuture = Future<void>.value();
      if (currentSong.lyricUrl != null) {
        lyricsFuture = _loadLyrics(currentSong.lyricUrl!);
      }

      // Đợi cả hai tác vụ (audio và lyrics) xong
      await Future.wait([audioFuture, lyricsFuture]);



      setState(() {
        _isLoadingLyrics = false; // Tắt trạng thái tải lyrics
      });
      _audioPlayer.play();
    }
  }


// Tải lời bài hát
  Future<void> _loadLyrics(String lyricUrl) async {
    try {
      final directLink = convertDriveLinkToDirectLink(lyricUrl);
      final response = await http.get(Uri.parse(directLink));

      if (response.statusCode == 200) {
        final content = utf8.decode(response.bodyBytes);
        final parsedLyrics = Lrc.parse(content);
        setState(() {
          _lyrics = parsedLyrics.lyrics
              .map((lrcLine) => LyricsLine(
                    timestamp: lrcLine.timestamp,
                    text: _removeTimestamp(lrcLine.formattedLine),
                  ))
              .toList();
        });
      } else {
        throw Exception('Failed to load lyrics');
      }
    } catch (e) {
      debugPrint("Error loading lyrics: $e");
    }
  }

  // Hàm này giúp lọc bỏ timestamp khỏi mỗi dòng lời bài hát
  String _removeTimestamp(String line) {
    final regExp = RegExp(r'\[\d{2}:\d{2}\.\d{2,3}\]');
    return line
        .replaceAll(regExp, '')
        .trim(); // Loại bỏ timestamp và xóa khoảng trắng thừa
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _rotationController.dispose();
    _scrollController.dispose();

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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.only(top:30.0),
          child: Container(
            color: const Color(0xFF121212),
            child: Stack(
              alignment: Alignment.center,
              children: [

                // Nút quay lại ở bên trái
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25,),
                      onPressed: () {
                        Navigator.pop(context); // Quay lại màn hình trước
                      },
                    ),
                  ),
                ),
                // Thanh chỉ số trang ở giữa
                SmoothPageIndicator(
                  controller: _pageController, // Sử dụng PageController
                  count: 2, // Số lượng trang trong PageView
                  effect: WormEffect(
                    dotWidth: 18.0,
                    dotHeight: 3.0,
                    activeDotColor: Colors.white,
                    dotColor: Colors.grey.withOpacity(0.5),
                    spacing: 8.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
          height: 50,
        ),
        // Đĩa nhạc
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _rotationController,
              child: Container(
                width: 290,
                height: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                        convertDriveLinkToDirectLink(currentSong.coverUrl)),
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
                    icon: Icon(Icons.list, size: 30, color: Colors.grey),
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
                  currentSong.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentSong.artist,
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
                        size: 25, color: Colors.grey),
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
              icon: Icon(Icons.shuffle, size: 25, color: isShuffle ? Color(0xFF005609) : Colors.grey),
              onPressed: () {
                setState(() {
                  isShuffle = !isShuffle;  // Chuyển đổi giữa chế độ Shuffle
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous,
                  size: 40, color: Color(0xFF005609)),
              onPressed: playPreviousSong,
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
                    duration: const Duration(milliseconds: 200),
                    // Thời gian chuyển đổi
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: Tween<double>(begin: 0.75, end: 1.0)
                            .animate(animation), // Hiệu ứng xoay nhẹ
                        child: child,
                      );
                    },
                    child: Container(
                      key: ValueKey<bool>(playing),
                      // Để AnimatedSwitcher nhận diện trạng thái thay đổi
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
                          playing ? Icons.pause : Icons.play_arrow,
                          // Biểu tượng thay đổi
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
              onPressed: playNextSong,
            ),
            IconButton(
              icon: Icon(Icons.repeat, size: 25, color: isRepeat ? Color(0xFF005609) : Colors.grey),
              onPressed: () {
                setState(() {
                  isRepeat = !isRepeat;  // Chuyển đổi giữa chế độ Repeat
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLyricsPage() {
    return Stack(
      children: [
        NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            // Phát hiện người dùng cuộn
            if (notification.direction != ScrollDirection.idle) {
              if (!_isUserScrolling) {
                setState(() {
                  _isUserScrolling = true;
                });
              }
            } else if (_isUserScrolling) {
              // Người dùng ngừng cuộn, kích hoạt lại cuộn tự động
              setState(() {
                _isUserScrolling = false;
              });
            }
            return true;
          },
          child: StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;

              // Tìm dòng lyrics hiện tại dựa trên thời gian (timestamp)
              int currentIndex = 0;
              for (int i = 0; i < _lyrics.length; i++) {
                if (position >= _lyrics[i].timestamp) {
                  currentIndex = i;
                } else {
                  break;
                }
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients && !_isUserScrolling) {
                  final lineHeight = _getLineHeight(context);

                  if (lineHeight == 0) {
                    print("Line height is 0, skipping scroll.");
                    return;
                  }

                  // Vị trí hiện tại của ScrollView
                  final visibleTopOffset = _scrollController.offset;

                  // Tính toán vị trí của dòng đang phát (currentIndex) theo pixel
                  double targetOffset =
                      _getOffsetForTimestamp(_lyrics[currentIndex].timestamp);

                  // Giới hạn offset để không vượt quá phạm vi cuộn
                  final maxScrollOffset =
                      _scrollController.position.maxScrollExtent;
                  final minScrollOffset = 0.0;
                  targetOffset =
                      targetOffset.clamp(minScrollOffset, maxScrollOffset);

                  // Tính toán khoảng cách cuộn
                  final distance = (visibleTopOffset - targetOffset).abs();

                  // Tính toán thời gian cuộn động dựa trên khoảng cách
                  int durationInMs = (distance / lineHeight * 100)
                      .toInt(); // Tăng tốc độ cuộn nếu khoảng cách dài hơn
                  durationInMs = durationInMs.clamp(
                      20, 500); // Giới hạn thời gian cuộn tối thiểu và tối đa

                  // Kiểm tra nếu cần cuộn để câu mới thay thế câu cũ ở đầu list
                  if (!_isUserScrolling && distance > lineHeight * 0.5) {
                    _scrollController.animateTo(
                      targetOffset,
                      duration: Duration(milliseconds: durationInMs),
                      curve: Curves.linear,
                    );
                  }
                }
              });
              return Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 300),
                child: _isLoadingLyrics
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        itemCount: _lyrics.length,
                        itemBuilder: (context, index) {
                          final isCurrentLine = index == currentIndex;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Text(
                              _lyrics[index].text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isCurrentLine ? 20 : 16,
                                fontWeight: isCurrentLine
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCurrentLine
                                    ? Color(0xFF005609)
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 70,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh tiến trình
              StreamBuilder<DurationState>(
                stream: _durationStateStream,
                builder: (context, snapshot) {
                  final durationState = snapshot.data;
                  final progress = durationState?.position ?? Duration.zero;
                  final buffered =
                      durationState?.bufferedPosition ?? Duration.zero;
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
              SizedBox(height: 20),
              // Nút điều khiển
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle, size: 25, color: isShuffle ? Color(0xFF005609) : Colors.grey),
                    onPressed: () {
                      setState(() {
                        isShuffle = !isShuffle;  // Chuyển đổi giữa chế độ Shuffle
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        size: 40, color: Color(0xFF005609)),
                    onPressed: playPreviousSong,
                  ),
                  StreamBuilder<PlayerState>(
                    stream: _audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing ?? false;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return const CircularProgressIndicator(
                            color: Colors.white);
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
                          duration: const Duration(milliseconds: 200),
                          // Thời gian chuyển đổi
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: Tween<double>(begin: 0.75, end: 1.0)
                                  .animate(animation), // Hiệu ứng xoay nhẹ
                              child: child,
                            );
                          },
                          child: Container(
                            key: ValueKey<bool>(playing),
                            // Để AnimatedSwitcher nhận diện trạng thái thay đổi
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
                                playing ? Icons.pause : Icons.play_arrow,
                                // Biểu tượng thay đổi
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
                    onPressed: playNextSong,
                  ),
                  IconButton(
                    icon: Icon(Icons.repeat, size: 25, color: isRepeat ? Color(0xFF005609) : Colors.grey),
                    onPressed: () {
                      setState(() {
                        isRepeat = !isRepeat;  // Chuyển đổi giữa chế độ Repeat
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getLineHeight(BuildContext context) {
    final textStyle =
        TextStyle(fontSize: 20); // Dùng fontSize 20 cho dòng hiện tại
    final textPainter = TextPainter(
      text: TextSpan(text: 'Sample Line', style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size.height +
        8 * 2; // Thêm padding vertical (8 top, 8 bottom)
  }

  double _getOffsetForTimestamp(Duration timestamp) {
    // Tính toán vị trí cuộn dựa trên timestamp
    final lineHeight = _getLineHeight(context);
    final lineIndex =
        _lyrics.indexWhere((lyric) => lyric.timestamp == timestamp);

    // Giả sử mỗi dòng có độ cao cố định
    return lineIndex * lineHeight;
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

class LyricsLine {
  final Duration timestamp;
  final String text;

  LyricsLine({required this.timestamp, required this.text});
}
