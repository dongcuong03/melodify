import 'package:flutter/material.dart';
import 'package:melodify/screens/admin/song/admin_detail_song_screen.dart';
import 'package:provider/provider.dart';
import '../../../models/song_model.dart';
import '../../../providers/song_provider.dart';
import '../../../widgets/admin_search_widget.dart';
import 'admin_add_song_screen.dart';

class AdminManagerSongScreen extends StatefulWidget {
  const AdminManagerSongScreen({Key? key}) : super(key: key);

  @override
  State<AdminManagerSongScreen> createState() => _AdminManagerSongScreenState();
}

class _AdminManagerSongScreenState extends State<AdminManagerSongScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // Biến lưu trữ từ khóa tìm kiếm

  int _currentPage = 0;
  static const int _itemsPerPage = 4;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    await Provider.of<SongProvider>(context, listen: false).fetchSongs();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  //hàm chuyển link ảnh google từ dạng chia sẻ sang link xem trực tiếp => mục đich để hiển thị ảnh
  String convertDriveLinkToDirectLink(String sharedLink) {
    final RegExp regExp = RegExp(r'\/d\/(.*)\/view');
    final match = regExp.firstMatch(sharedLink);

    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    return sharedLink; // Trả về link gốc nếu không phải là link Google Drive hợp lệ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<SongProvider>(
        builder: (context, songProvider, child) {
          if (songProvider.songs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Lọc theo từ khóa tìm kiếm
          final filteredSongs = songProvider.songs.where((songData) {
            final song = songData['song'] as SongModel;
            return song.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

          // Chia genres thành các trang, mỗi trang 6 bài hát
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage) > filteredSongs.length
              ? filteredSongs.length
              : startIndex + _itemsPerPage;
          final currentPageSongs = filteredSongs.sublist(startIndex, endIndex);

          final totalPages = (filteredSongs.length / _itemsPerPage).ceil();

          // Logic để hiển thị các số trang với dấu "..."
          List<Widget> pageNumbers = [];
          if (totalPages <= 6) {
            pageNumbers = List.generate(totalPages, (index) {
              return _buildPageNumber(index + 1);
            });
          } else {
            if (_currentPage < 3) {
              pageNumbers = [
                _buildPageNumber(1),
                _buildPageNumber(2),
                _buildPageNumber(3),
                _buildPageNumber(4),
                _buildPageNumber(5),
                _buildPageEllipsis(),
                _buildPageNumber(totalPages),
              ];
            } else if (_currentPage > totalPages - 4) {
              pageNumbers = [
                _buildPageNumber(1),
                _buildPageEllipsis(),
                _buildPageNumber(totalPages - 4),
                _buildPageNumber(totalPages - 3),
                _buildPageNumber(totalPages - 2),
                _buildPageNumber(totalPages - 1),
                _buildPageNumber(totalPages),
              ];
            } else {
              pageNumbers = [
                _buildPageNumber(1),
                _buildPageEllipsis(),
                _buildPageNumber(_currentPage),
                _buildPageNumber(_currentPage + 1),
                _buildPageNumber(_currentPage + 2),
                _buildPageEllipsis(),
                _buildPageNumber(totalPages),
              ];
            }
          }

          return Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: AdminSearchWidget(
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged, // Thêm tìm kiếm
                  hinText: 'Tìm kiếm bài hát ...',
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentPageSongs.length,
                  itemBuilder: (context, index) {
                    final songDataItem = currentPageSongs[index];
                    final songItem = songDataItem['song'] as SongModel;
                    final songIdItem = songDataItem['id'] as String;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 18.0),
                      child: Container(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                convertDriveLinkToDirectLink(songItem.coverUrl),
                                width: 53,
                                height: 53,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  // Hiển thị hiệu ứng xoay tròn khi đang tải ảnh
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    songItem.title
                                        .split(' ')
                                        .map((word) => word.isNotEmpty
                                        ? word[0].toUpperCase() +
                                        word.substring(1).toLowerCase()
                                        : '')
                                        .join(' '),
                                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    songItem.artist,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              color: Colors.white.withOpacity(0.95),
                              icon: Icon(Icons.more_vert),
                              onSelected: (value) {
                                switch (value) {
                                  case 'view':
                                  // Thêm hành động khi chọn "Xem"
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminDetailSongScreen(
                                          song: songItem,
                                          songId: songIdItem,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 'edit':
                                  // Thêm hành động khi chọn "Sửa"
                                    break;
                                  case 'delete':
                                  // Thêm hành động khi chọn "Xóa"
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility, color: Colors.yellow),
                                      SizedBox(width: 10),
                                      Text('Xem'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 10),
                                      Text('Sửa'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text('Xóa'),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút Trước
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    // Các số trang
                    ...pageNumbers,
                    // Nút Sau
                    IconButton(
                      onPressed: _currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0, right: 20.0),
        child: FloatingActionButton(
          onPressed: () async {
            // Điều hướng đến màn hình thêm bài hát và gọi _fetchSongs khi quay lại
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminAddSongScreen(),
              ),
            );
            _fetchSongs();
          },
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xFF005609),
        ),
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = page - 1;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _currentPage == page - 1 ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: _currentPage == page - 1 ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildPageEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        "...",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
