import 'package:flutter/material.dart';
import 'package:melodify/providers/genre_provider.dart';
import 'package:provider/provider.dart';

import '../../../utils/validators/auth_validator.dart';
import '../../../widgets/admin_search_widget.dart';

class AdminManagerGenreScreen extends StatefulWidget {
  const AdminManagerGenreScreen({super.key});

  @override
  State<AdminManagerGenreScreen> createState() =>
      _AdminManagerGenreScreenState();
}

class _AdminManagerGenreScreenState extends State<AdminManagerGenreScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Validator _validator = Validator();
  String _searchQuery = ''; // Biến lưu trữ từ khóa tìm kiếm

  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    await Provider.of<GenreProvider>(context, listen: false).fetchGenres();
  }

  void _showAddGenreDialog() {
    _nameController.clear(); // Đặt lại lỗi khi mở hộp thoại mới

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,

              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Thêm thể loại"),
                  Container(
                    height: 35,
                    width: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _nameController.clear();
                        Provider.of<GenreProvider>(context, listen: false)
                            .clearErrorMessage();
                        Navigator.pop(context);
                      },
                      color: Colors.white,
                      iconSize: 18,
                    ),
                  ),
                ],
              ),
              content: Consumer<GenreProvider>(
                builder: (context, genreProvider, child) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            labelText: 'Nhập tên thể loại',
                            labelStyle: const TextStyle(color: Colors.black87),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 20.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorText: genreProvider.errorMessage,
                          ),
                          validator: (value) => _validator.validateGenreName(value),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final genreName = _nameController.text.trim();
                      final provider = Provider.of<GenreProvider>(context, listen: false);
                      await provider.addGenre(genreName);

                      if (provider.errorMessage == null) {
                        _nameController.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Thêm thể loại thành công!',
                              style: TextStyle(color: Colors.black),
                            ),
                            duration: const Duration(seconds: 6),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 20,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        _fetchGenres();
                      } else {
                        setState(() {}); // Cập nhật để hiển thị lỗi nếu có
                      }
                    }
                  },
                  child: const Text(
                    "Thêm",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF005609),

                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 22),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 2,),
                TextButton(
                  onPressed: () {
                    _nameController.clear();
                    Provider.of<GenreProvider>(context, listen: false)
                        .clearErrorMessage();
                    Navigator.pop(context);
                  },
                  child: const Text("Hủy", style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.4),

                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showUpdateGenreDialog(String value) {
    _nameController.text = value;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,

              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Sửa thể loại"),
                  Container(
                    height: 35,
                    width: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _nameController.clear();
                        Provider.of<GenreProvider>(context, listen: false)
                            .clearErrorMessage();
                        Navigator.pop(context);
                      },
                      color: Colors.white,
                      iconSize: 18,
                    ),
                  ),
                ],
              ),
              content: Consumer<GenreProvider>(
                builder: (context, genreProvider, child) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            labelText: 'Nhập tên thể loại',
                            labelStyle: const TextStyle(color: Colors.black87),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 20.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorText: genreProvider.errorMessage,
                          ),
                          validator: (value) => _validator.validateGenreName(value),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final genreName = _nameController.text.trim();
                      final provider = Provider.of<GenreProvider>(context, listen: false);
                      await provider.updateGenre(value, genreName);

                      if (provider.errorMessage == null) {
                        _nameController.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sửa thể loại ${value} thành công!',
                              style: TextStyle(color: Colors.black),
                            ),
                            duration: const Duration(seconds: 6),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 20,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      } else {
                        setState(() {}); // Cập nhật để hiển thị lỗi nếu có
                      }
                    }
                  },
                  child: const Text(
                    "Sửa",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF005609),

                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 22),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 2,),
                TextButton(
                  onPressed: () {
                    _nameController.clear();
                    Provider.of<GenreProvider>(context, listen: false)
                        .clearErrorMessage();
                    Navigator.pop(context);
                  },
                  child: const Text("Hủy", style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.4),

                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<GenreProvider>(
        builder: (context, genreProvider, child) {
          if (genreProvider.genres.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Lọc theo từ khóa tìm kiếm
          final filteredGenres = genreProvider.genres
              .where((genre) => genre.genreName.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          // Chia genres thành các trang, mỗi trang 6 thể loại
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage) > filteredGenres.length
              ? filteredGenres.length
              : startIndex + _itemsPerPage;
          final currentPageGenres = filteredGenres.sublist(startIndex, endIndex);

          final totalPages = (filteredGenres.length / _itemsPerPage).ceil();

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
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: AdminSearchWidget(
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged, // Thêm tìm kiếm
                  hinText: 'Tìm kiếm thể loại ...',
                ),
              ),
              SizedBox(height: 30,),
              Expanded(
                child: ListView.builder(
                  itemCount: currentPageGenres.length,
                  itemBuilder: (context, index) {
                    final genre = currentPageGenres[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 35.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.grey, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  genre.genreName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showUpdateGenreDialog(genre.genreName);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    // Xử lý xóa thể loại
                                    final confirmDelete = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false, // Không tự tắt khi nhấn vùng trống
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Xác nhận xóa"),
                                              Container(
                                                height: 33,
                                                width: 33,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red,
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () {
                                                    _nameController.clear();
                                                    Provider.of<GenreProvider>(context, listen: false)
                                                        .clearErrorMessage();
                                                    Navigator.pop(context);
                                                  },
                                                  color: Colors.white,
                                                  iconSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Text("Bạn xác nhận xóa thể loại \"${genre.genreName}\"?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Color(0xFF005609), // Màu xanh cho nút Hủy
                                                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),

                                              ),
                                              child: const Text(
                                                "Hủy",
                                                style: TextStyle(fontWeight: FontWeight.bold), // Làm nổi bật nút Hủy
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  // Gọi hàm xóa từ GenreProvider
                                                  await Provider.of<GenreProvider>(context, listen: false)
                                                      .deleteGenre(genre.genreName);

                                                  // Nếu xóa thành công, đóng hộp thoại và hiển thị SnackBar
                                                  Navigator.pop(context, true);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Xóa thể loại ${genre.genreName} thành công!",
                                                        style: TextStyle(color: Colors.black),
                                                      ),
                                                      duration: const Duration(seconds: 6),
                                                      behavior: SnackBarBehavior.floating,
                                                      margin: const EdgeInsets.only(
                                                        left: 16,
                                                        right: 16,
                                                        bottom: 20,
                                                      ),
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  );// Cập nhật lại danh sách thể loại sau khi xóa
                                                } catch (e) {
                                                  // Nếu có lỗi khi xóa, hiển thị thông báo lỗi
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Không thể xóa thể loại: ${genre.genreName}"),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: Colors.grey.withOpacity(0.3), // Màu xám cho nút Xóa
                                                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
                                              ),
                                              child: const Text("Xóa"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmDelete == true) {
                                      // await genreProvider.deleteGenre(genre.id);
                                      _fetchGenres();
                                    }
                                  },
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
          onPressed: _showAddGenreDialog,
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
