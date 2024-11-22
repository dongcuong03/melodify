import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../models/song_model.dart';
import '../../../providers/genre_provider.dart';
import '../../../providers/google_drive_provider.dart';
import '../../../providers/song_provider.dart';

class AdminUpdateSongScreen extends StatefulWidget {
  final SongModel song;
  final String songId;

  const AdminUpdateSongScreen({
    Key? key,
    required this.song,
    required this.songId,
  }) : super(key: key);

  @override
  State<AdminUpdateSongScreen> createState() => _AdminUpdateSongScreenState();
}

class _AdminUpdateSongScreenState extends State<AdminUpdateSongScreen> {
  // Các folderId cố định
  final String folderIdSong = '1ymFzZVsyIWTq18U1Ef0jkFIYbHMzW-uY';
  final String folderIdLrc = '15UASsNW7g9a8U8GKtf_cyWjN5qR217lf';
  final String folderIdCover = '1HFUJl3y3g_RQd2IuR99870SSaKn-SuHy';

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _audioKey =
  GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _lyricKey =
  GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _coverKey =
  GlobalKey<FormFieldState<String>>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String? _selectedGenre;

  // Các controller và biến cần thiết cho các file (audio, lyrics, cover)
  bool _isUploadingAudio = false;
  bool _isUploadingLyrics = false;
  bool _isUploadingCover = false;
  String? _audioFile;
  String? _lyricFile;
  String? _coverFile;

  String? _audioURL;
  String? _lyricURL;
  String? _coverURL;

  String _errorAudioFile = '';
  String _errorLRCFile = '';
  String _errorCoverFile = '';
  String _errorAudioURL = '';
  String _errorLRCURL = '';
  String _errorCoverURL = '';
  late File selectedFile;

  bool isAudioSaved = false;
  bool isLyricSaved = false;
  bool isCoverSaved = false;

  bool isButtonEnabled = true;




  @override
  void initState() {
    super.initState();
    // Gọi fetchGenres khi màn hình khởi tạo
    Provider.of<GenreProvider>(context, listen: false).fetchGenres();

    requestStoragePermission();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _titleController.text = widget.song.title;
        _artistController.text = widget.song.artist;
        _selectedGenre = widget.song.genre;

        _audioURL = widget.song.audioUrl;
        _lyricURL = widget.song.lyricUrl;
        _coverURL = widget.song.coverUrl;
        isButtonEnabled = false;
        // Gọi phương thức async để lấy đường dẫn file
        _initializeFilePaths();
      });
    });


  }

  // Hàm lấy fileId từ URL
  Future<String?> _getFileId(BuildContext context, String URL) async {
    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);
    try {
      final fileId = await provider.extractFileId(URL);
      return fileId;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lấy fileID: $e')),
      );
      return null;
    }
  }

  // Hàm lấy tên file từ fileId
  Future<String?> _getFileName(BuildContext context, String URL) async {
    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);
    String? _fileIdFromDB = await _getFileId(context, URL);
    if (_fileIdFromDB != null) {
      try {
        final fileName = await provider.fetchFileName(_fileIdFromDB);
        return fileName;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lấy tên file: $e')),
        );
      }
    }
    return null;
  }

  Future<String> getFilePathFromDownloads(BuildContext context, String URL) async {
    try {
      // Giả sử bạn đã có tên tệp từ URL (hoặc có thể dùng phương thức tương tự như đã làm trước đó)
      String? fileName = await _getFileName(context, URL);
      if (fileName != null) {
        // Lấy thư mục Downloads
        final directory = Directory('/storage/emulated/0/Download');

        // Xây dựng đường dẫn tới tệp trong thư mục Downloads
        final filePath = path.join(directory.path, fileName);

        // Kiểm tra tệp có tồn tại không
        final file = File(filePath);
        if (await file.exists()) {
          print("Tệp tồn tại tại: $filePath");
          return filePath; // Trả về đường dẫn nếu tệp tồn tại
        } else {
          throw Exception("Tệp không tồn tại tại đường dẫn: $filePath");
        }
      } else {
        throw Exception("Không thể lấy tên tệp từ URL");
      }
    } catch (e) {
      print("Lỗi khi lấy đường dẫn tệp: $e");
      throw Exception("Lỗi khi tải tệp: $e");
    }
  }


  Future<void> _initializeFilePaths() async {
    try {
      final futures = <Future>[]; // Danh sách các tệp cần tải

      if (_audioURL != null) {
        futures.add(getFilePathFromDownloads(context, widget.song.audioUrl).then((filePath) {
          setState(() {
            _audioFile = filePath;
            isAudioSaved = true;
          });

        }));
      }
      if (_lyricURL != null) {
        futures.add(getFilePathFromDownloads(context, widget.song.lyricUrl).then((filePath) {
          setState(() {
            _lyricFile = filePath;
            isLyricSaved = true;
          });

        }));
      }
      if (_coverURL != null) {
        futures.add(getFilePathFromDownloads(context,widget.song.coverUrl).then((filePath) {
          setState(() {
            _coverFile = filePath;
            isCoverSaved = true;
          });

        }));
      }

      await Future.wait(futures); // Đợi tất cả các tệp được tải xuống
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải tệp: $e')),
      );
    }
  }

  //Hàm yêu cầu truy cập bộ nhớ ngoài
  void requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      print("Quyền truy cập bộ nhớ ngoài đã được cấp.");
    } else {
      print("Không có quyền truy cập bộ nhớ ngoài.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<GenreProvider>(
          builder: (context, genreProvider, child) {
            // Nếu danh sách thể loại đang trống, hiển thị loading indicator
            if (genreProvider.genres.isEmpty) {
              if (genreProvider.errorMessage != null) {
                return Center(
                  child: Text(genreProvider.errorMessage!),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Center(
                          child: Text(
                            'Sửa Bài Hát',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005609)),
                          )),
                      const SizedBox(
                        height: 40,
                      ),
                      _buildTextField("Tên bài hát (*)", _titleController),
                      const SizedBox(height: 25),
                      _buildTextField("Nghệ sĩ (*)", _artistController),
                      const SizedBox(height: 25),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Thể loại (*)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade400, width: 1.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            // Giảm chiều cao
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade400, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1.5),
                            ),
                          ),
                          dropdownColor: Colors.white,
                          // Nền trắng cho menu
                          value: _selectedGenre,
                          items: genreProvider.genres.map((genre) {
                            return DropdownMenuItem<String>(
                              value: genre.genreName,
                              child: Text(
                                genre.genreName,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGenre = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Vui lòng chọn thể loại';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildFilePicker("audio", "Bài hát", _audioFile,
                          _isUploadingAudio, isAudioSaved),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          '$_errorAudioFile',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFilePicker("lyrics", "Lời bài hát", _lyricFile,
                          _isUploadingLyrics, isLyricSaved),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "$_errorLRCFile",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFilePicker("cover", "Ảnh bìa", _coverFile,
                          _isUploadingCover, isCoverSaved),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "$_errorCoverFile",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 45),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              validateFile();
                              if (_formKey.currentState!.validate()) {
                                if (_audioFile == null ||
                                    _lyricFile == null ||
                                    _coverFile == null ||
                                    _audioURL == null ||
                                    _lyricURL == null ||
                                    _coverURL == null) {
                                  validateFile();
                                } else {
                                  String titleNew = _titleController.text;
                                  String artistNew = _artistController.text;
                                  String genreNew = _selectedGenre.toString();
                                  String audioUrlNew =
                                      _audioKey.currentState?.value ?? "";
                                  String lyricUrlNew =
                                      _lyricKey.currentState?.value ?? "";
                                  String coverUrlNew =
                                      _coverKey.currentState?.value ?? "";


                                  final provider = Provider.of<SongProvider>(
                                      context, listen: false);
                                  await provider.updateSong(widget.songId, titleNew, artistNew, genreNew, audioUrlNew, lyricUrlNew, coverUrlNew);

                                  if (provider.errorMessage == null) {
                                    _titleController.clear();
                                    _artistController.clear();

                                    setState(() {
                                      _audioFile = null;
                                      _audioURL = null;
                                      _lyricFile = null;
                                      _lyricURL = null;
                                      _coverFile = null;
                                      _coverURL = null;
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Sửa thông tin bài hát ${widget.song.title
                                              .toLowerCase()} thành công!',
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
                                          borderRadius: BorderRadius.circular(
                                              8),
                                        ),
                                      ),
                                    );
                                  } else {
                                    setState(() {}); // Cập nhật để hiển thị lỗi nếu có
                                  }
                                }
                              }
                            },
                            child: const Text(
                              "Sửa",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF005609),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 22),
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                elevation: 10,
                                // Tăng độ nổi bật cho nút
                                shadowColor: Colors.grey.withOpacity(0.5)),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Hủy",
                              style: TextStyle(color: Colors.black),
                            ),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.withOpacity(0.3),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 25),
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                elevation: 10,
                                // Tăng độ nổi bật cho nút
                                shadowColor: Colors.black.withOpacity(0.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void validateFile() {
    if (_audioFile == null) {
      setState(() {
        _errorAudioFile = 'Vui lòng chọn file bài hát';
      });
    } else {
      setState(() {
        _errorAudioFile = '';
      });
    }
    if (_lyricFile == null) {
      setState(() {
        _errorLRCFile = 'Vui lòng chọn file lời bài hát ';
      });
    } else {
      setState(() {
        _errorLRCFile = '';
      });
    }
    if (_coverFile == null) {
      setState(() {
        _errorCoverFile = 'Vui lòng chọn file ảnh bìa';
      });
    } else {
      setState(() {
        _errorCoverFile = '';
      });
    }
    if (_audioURL == null) {
      setState(() {
        _errorAudioURL = 'Vui lòng nhấn lưu bài hát để tiếc tục ';
      });
    } else {
      setState(() {
        _errorAudioURL = '';
      });
    }
    if (_lyricURL == null) {
      setState(() {
        _errorLRCURL = 'Vui lòng nhấn lưu lời bài hát để tiếc tục ';
      });
    } else {
      setState(() {
        _errorLRCURL = '';
      });
    }
    if (_coverURL == null) {
      setState(() {
        _errorCoverURL = 'Vui lòng nhấn lưu ảnh bìa để tiếc tục ';
      });
    } else {
      setState(() {
        _errorCoverURL = '';
      });
    }
  }

  // Hàm xây dựng TextField
  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          // Giảm chiều cao ô
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
      ),
    );
  }

  // Hàm xây dựng File Picker cho audio, lyrics, cover
  Widget _buildFilePicker(String type, String label, String? fileUrl,
      bool isUploading, bool isSaved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Text('$label (*)', style: TextStyle(fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Text(
            '(Vui lòng chọn file ${label
                .toLowerCase()} trong máy để lưu trữ tại hệ thống)',
            style: TextStyle(fontStyle: FontStyle.italic,
                color: Colors.black87,
                fontSize: 13),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: fileUrl == null
              ? () => _showFilePicker(type)
              : null, // Nếu đã có file, không cho phép chọn lại
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white, // Màu nền
              borderRadius: BorderRadius.circular(20), // Bo góc
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Màu bóng
                  blurRadius: 10, // Độ mờ của bóng
                  offset: Offset(0, 3), // Vị trí bóng
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: Stack(
              children: [
                // Nếu chưa có file, hiển thị icon thêm
                if (fileUrl == null && !isUploading)
                  Center(
                    child: Icon(
                      Icons.add_circle_outline_outlined,
                      size: 40,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                  )
                // Nếu đã có file, hiển thị biểu tượng file
                else
                  if (fileUrl != null && !isUploading)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _getFileIcon(fileUrl),
                            // Hiển thị biểu tượng phù hợp
                            Text(fileUrl
                                .split('/')
                                .last),
                            // Tên file
                          ],
                        ),
                      ),
                    )
                  // Nếu đang tải, hiển thị CircularProgressIndicator
                  else
                    if (isUploading)
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF005609)),
                        ),
                      ),
                // Vị trí của biểu tượng nút đóng hay chỉnh sửa
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(isSaved ? Icons.edit : Icons.close),
                    color: isSaved ? Colors.black87 : Colors.red,
                    onPressed: () {
                      if (isSaved) {
                        _showConfirmDialog(type);
                      } else {
                        setState(() {
                          if (type == "audio") {
                            _audioFile = null;
                            _audioURL = null;
                          } else if (type == "lyrics") {
                            _lyricFile = null;
                            _lyricURL = null;
                          } else if (type == "cover") {
                            _coverFile = null;
                            _coverURL = null;
                          }
                          isSaved = false;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        fileUrl != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                controller: TextEditingController(
                    text: type == "audio"
                        ? _audioURL
                        : type == "lyrics"
                        ? _lyricURL
                        : _coverURL),
                key: type == "audio"
                    ? _audioKey
                    : type == "lyrics"
                    ? _lyricKey
                    : _coverKey,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Đường dẫn ${label.toLowerCase()} ...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.6), width: 1.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.6), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                type == "audio"
                    ? _errorAudioURL
                    : type == "lyrics"
                    ? _errorLRCURL
                    : _errorCoverURL,
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: isButtonEnabled ? () async {
                _uploadFile(type, selectedFile);
                if (type == "audio") {
                  isAudioSaved = true;
                } else if (type == "lyrics") {
                  isLyricSaved = true;
                } else if (type == "cover") {
                  isCoverSaved = true;
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
                elevation: 5,
              ),
              child: Text(
                "Lưu ${label.toLowerCase()}",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        )
            : Container(),
      ],
    );
  }


  // Hàm hiển thị hộp thoại xác nhận
  void _showConfirmDialog(String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          title: Text("Xác nhận"),
          content: Text(
              "Hành động này sẽ xóa file đã lưu trữ để thay thế bằng file mới. Bạn có muốn tiếp tục?"),
          actions: [
            TextButton(
              child: Text("Hủy"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF005609), // Màu xanh cho nút Hủy
                padding: const EdgeInsets.symmetric(
                    vertical: 9, horizontal: 25),

              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            SizedBox(width: 2,),
            TextButton(
              child: Text("Tiếp tục"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey.withOpacity(0.3),
                // Màu xám cho nút Xóa
                padding: const EdgeInsets.symmetric(
                    vertical: 9, horizontal: 15),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                if (type == "audio") {
                  _deleteFile(_audioURL!);
                  setState(() {
                    _audioFile = null;
                    _audioURL = null;
                    isAudioSaved = false;
                    isButtonEnabled = true;
                  });
                } else if (type == "lyrics") {
                  _deleteFile(_lyricURL!);
                  setState(() {
                    _lyricFile = null;
                    _lyricURL = null;
                    isLyricSaved = false;
                    isButtonEnabled = true;
                  });
                } else if (type == "cover") {
                  _deleteFile(_coverURL!);
                  setState(() {
                    _coverFile = null;
                    _coverURL = null;
                    isCoverSaved = false;
                    isButtonEnabled = true;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

// Hàm để lấy biểu tượng tùy thuộc vào loại file
  Widget _getFileIcon(String fileUrl) {
    // Lấy phần mở rộng của file
    String extension = fileUrl
        .split('.')
        .last
        .toLowerCase();

    // Kiểm tra loại file và trả về biểu tượng tương ứng
    if (['mp3', 'wav', 'flac'].contains(extension)) {
      return Icon(Icons.library_music,
          size: 40, color: Color(0xFF005609)); // Biểu tượng nhạc
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return Icon(Icons.image,
          size: 40, color: Color(0xFF005609)); // Biểu tượng ảnh
    } else if (['pdf', 'txt', 'docx'].contains(extension)) {
      return Icon(Icons.description,
          size: 40, color: Color(0xFF005609)); // Biểu tượng tài liệu
    } else {
      return Icon(Icons.insert_drive_file,
          size: 40, color: Color(0xFF005609)); // Biểu tượng mặc định
    }
  }

  // Hàm để xử lý chọn file
  Future<void> _showFilePicker(String type) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!); // Lưu file đã chọn
        if (type == "audio") {
          _audioFile = selectedFile!.path;
        } else if (type == "lyrics") {
          _lyricFile = selectedFile!.path;
        } else if (type == "cover") {
          _coverFile = selectedFile!.path;
        }
      });
    }
  }

  // Hàm để upload file
  void _uploadFile(String type, File file) {
    switch (type) {
      case "audio":
      // Gọi hàm upload file cho audio
      // Thay thế _audioFile với kết quả sau khi upload nếu cần
        setState(() {
          _isUploadingAudio = true;
        });
        Provider.of<GoogleDriveProvider>(context, listen: false)
            .uploadFile(file, folderIdSong)
            .then((fileUrl) {
          setState(() {
            _audioURL = fileUrl;
            print('$_audioURL');
            _isUploadingAudio = false;
          });
        });
        break;

      case "lyrics":
      // Gọi hàm upload file cho lyrics
        setState(() {
          _isUploadingLyrics = true;
        });
        Provider.of<GoogleDriveProvider>(context, listen: false)
            .uploadFile(file, folderIdLrc)
            .then((fileUrl) {
          setState(() {
            _lyricURL = fileUrl;
            print('$_lyricURL');
            _isUploadingLyrics = false;
          });
        });
        break;

      case "cover":
      // Gọi hàm upload file cho cover
        setState(() {
          _isUploadingCover = true;
        });
        Provider.of<GoogleDriveProvider>(context, listen: false)
            .uploadFile(file, folderIdCover)
            .then((fileUrl) {
          setState(() {
            _coverURL = fileUrl;
            print('$_coverURL');
            _isUploadingCover = false;
          });
        });
        break;
    }
  }

  void _deleteFile(String fileId) async {
    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);
    await provider.deleteFile(fileId);
  }
}
