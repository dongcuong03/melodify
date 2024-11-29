import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:melodify/screens/user/home/user_play_song_screen.dart';
import 'package:provider/provider.dart';
import '../../../models/song_model.dart';
import '../../../providers/song_provider.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late ScrollController _scrollController;

  String convertDriveLinkToDirectLink(String sharedLink) {
    final RegExp regExp = RegExp(r'\/d\/(.*)\/view');
    final match = regExp.firstMatch(sharedLink);

    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    return sharedLink;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      if (songProvider.coverUrls.isEmpty) {
        songProvider.fetchCoverUrls();
      }
      songProvider.fetchSongs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<SongProvider>(
              builder: (context, songProvider, child) {
                if (songProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (songProvider.coverUrls.isEmpty) {
                  return Center(child: Text('No images found'));
                }

                return CarouselSlider(
                  options: CarouselOptions(
                    height: 250.0,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration: Duration(milliseconds: 1200),
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: songProvider.coverUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 15.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Text(
                    'Album mới',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Text(
                    'Bài hát mới',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              height: 350,
              child: Consumer<SongProvider>(
                builder: (context, songProvider, child) {
                  return Padding(
                      padding: const EdgeInsets.only(right: 17.0, left: 20.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF1E1E1E), // Màu nền nhạt hơn
                            borderRadius: BorderRadius.circular(10.0), // Bo góc
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0, top: 8.0, bottom: 8.0),
                            child: ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbColor:
                                    MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),

                                // Thay đổi màu của thanh cuộn

                                radius: Radius.circular(10), // Bo góc cho thanh cuộn
                              ),
                              child: Scrollbar(
                                  controller: _scrollController,
                                  radius: Radius.circular(10.0),
                                  thumbVisibility: true,
                                  child: ListView.separated(
                                    controller: _scrollController,
                                    itemCount: songProvider.songs.length,
                                    itemBuilder: (context, index) {
                                      final songDataListView =
                                          songProvider.songs[index];
                                      final songItem =
                                          songDataListView['song'] as SongModel;
                                      final songIdItem =
                                          songDataListView['id'] as String;
                                      final List<SongModel> listSongs =
                                          songProvider
                                              .songs
                                              .map((songDataItem) =>
                                                  songDataItem['song']
                                                      as SongModel)
                                              .toList();
                                      return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserPlaySongScreen(
                                                  song: songItem,
                                                  listSongs: listSongs,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.network(
                                                    convertDriveLinkToDirectLink(
                                                        songItem.coverUrl),
                                                    width: 53,
                                                    height: 53,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2.0,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 20.0),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        songItem.title
                                                            .split(' ')
                                                            .map((word) => word
                                                                    .isNotEmpty
                                                                ? word[0]
                                                                        .toUpperCase() +
                                                                    word
                                                                        .substring(
                                                                            1)
                                                                        .toLowerCase()
                                                                : '')
                                                            .join(' '),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14.0),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                      Text(
                                                        songItem.artist,
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.5),
                                                          fontSize: 13.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  color: Color(0xFF0F0F0F),
                                                  iconColor: Colors.white,
                                                  icon: const Icon(
                                                      Icons.more_vert),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15), // Bo góc popup
                                                  ),
                                                  onSelected: (value) {
                                                    switch (value) {
                                                      case 'like':
                                                        // Thêm hành động khi chọn "like"
                                                        break;
                                                      case 'playList':
                                                        // Thêm hành động khi chọn "playList"
                                                        break;
                                                      case 'comment':
                                                        // Thêm hành động khi chọn "comment"
                                                        break;
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 'like',
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .favorite_outline,
                                                              color:
                                                                  Colors.white),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'playList',
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.list,
                                                              color:
                                                                  Colors.white),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'comment',
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .comment_outlined,
                                                              color:
                                                                  Colors.white),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ));
                                    },
                                    separatorBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 23.0, right: 32),
                                        child: Divider(
                                            color:
                                                Colors.grey.withOpacity(0.3)),
                                      ); // Tạo dấu gạch giữa các bài hát
                                    },
                                  )),
                            ),
                          )));
                },
              ),
            ),
            SizedBox(
              height: 80,
            )
          ],
        ),
      ),
    );
  }
}
