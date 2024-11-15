import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thư viện format ngày tháng
import '../../../models/song_model.dart';

class AdminDetailSongScreen extends StatefulWidget {
  final SongModel song;
  final String songId;

  const AdminDetailSongScreen({
    Key? key,
    required this.song,
    required this.songId,
  }) : super(key: key);

  @override
  State<AdminDetailSongScreen> createState() => _AdminDetailSongScreenState();
}

class _AdminDetailSongScreenState extends State<AdminDetailSongScreen> {
  // Hàm chuyển đổi Timestamp sang định dạng ngày tháng
  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return ""; // Trả về chuỗi mặc định nếu null
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  // Widget tạo ra TextField với giao diện đẹp
  Widget buildCustomField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1), // Màu nền input
          borderRadius: BorderRadius.circular(25.0), // Bo góc
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1), // Màu bóng
              blurRadius: 4, // Độ mờ của bóng
              offset: const Offset(0, 2), // Độ dịch chuyển bóng
            ),
          ],
        ),
        child: TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: Colors.transparent, // Để phần nền không bị đè lên màu bóng
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0), // Bo góc
              borderSide: const BorderSide(color: Colors.grey), // Viền màu
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Center(
                  child: Text(
                    'Chi Tiết Bài Hát',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005609)),
                  )),
              const SizedBox(
                height: 20,
              ),
              buildCustomField('ID:', widget.songId),
              buildCustomField('Tên bài hát:', widget.song.title),
              buildCustomField('Nghệ sĩ:', widget.song.artist),
              buildCustomField('Thể loại:', widget.song.genre),
              buildCustomField('URL bài hát:', widget.song.audioUrl),
              buildCustomField('URL lời bài hát:', widget.song.lyricUrl),
              buildCustomField('URL ảnh bìa:', widget.song.coverUrl),
              buildCustomField(
                'Created At:',
                formatDate(widget.song.createdAt?.toDate()),
              ),
              buildCustomField(
                'Updated At:',
                widget.song.updatedAt != null
                    ? formatDate(widget.song.updatedAt!.toDate())
                    : "null", // Xử lý khi null
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Quay lại",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
