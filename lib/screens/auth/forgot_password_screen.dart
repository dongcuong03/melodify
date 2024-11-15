import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/firebase_auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/validators/auth_validator.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  //Biến theo dõi trang thái load khi đăng nhập bằng email, password
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  final Validator _validator = Validator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black87,
            child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 120,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Melodify',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0x80005609),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Color(0xBF005609),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xff005609),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 123,
                      ),
                      const Text(
                        'Vui lòng nhập email đã đăng ký để đặt lại mật khẩu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(
                        height: 47,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ô nhập Email
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  filled: true,
                                  // Bật màu nền
                                  fillColor: Colors.white.withOpacity(0.1),
                                  // Màu nền nhẹ
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Colors.white,
                                  ),
                                  labelText: 'Email',
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 20.0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    // Bo góc mềm mại
                                    borderSide: BorderSide
                                        .none, // Loại bỏ viền mặc định
                                  ),
                                  errorText: _emailError, // Hiển thị lỗi nếu có
                                ),
                                validator: (value) =>
                                    _validator.validateEmail(value),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 27.0),
                        child: Container(
                          width: 180.0,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF005609), Colors.white],
                              // Trộn màu trắng và xanh
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: OutlinedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Cập nhật trạng thái loading
                                setState(() {
                                  _isLoading = true;
                                  _emailError = null;
                                });
                                String email = _emailController.text.trim();

                                // Kiểm tra xem email có tồn tại không
                                bool emailExists =
                                    await AuthService().isEmailExists(email);

                                if (!emailExists) {
                                  setState(() {
                                    _isLoading = false; // Kết thúc loading
                                    _emailError =
                                        'Email không tồn tại trong hệ thống'; // Cập nhật lỗi email
                                  });
                                  return; // Thoát hàm nếu email đã tồn tại
                                }
                                try {
                                  await Provider.of<FirebaseAuthProvider>(
                                          context,
                                          listen: false)
                                      .sendPasswordResetEmail(email);

                                  setState(() {
                                    _isLoading = false;
                                  });
                                  // Hiển thị thông báo
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.black12,
                                    barrierDismissible: false,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.black87,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(
                                              20), // Bo góc
                                        ),
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          // Căn trái nội dung
                                          children: [
                                            const SizedBox(height: 10),
                                            const Text(
                                              'Thông báo',
                                              style: TextStyle(
                                                fontSize: 23,
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .white, // Màu chữ tiêu đề
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            // Khoảng cách
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              // Căn trái cho icon và văn bản
                                              children: [
                                                const Icon(
                                                  Icons.mail_outline,
                                                  size: 40,
                                                  color: Colors
                                                      .white, // Màu biểu tượng
                                                ),
                                                const SizedBox(width: 20),
                                                // Khoảng cách giữa biểu tượng và văn bản
                                                const Expanded(
                                                  // Đảm bảo văn bản chiếm toàn bộ chiều rộng còn lại
                                                  child: Text(
                                                    'Tin nhắn xác nhận đặt lại mật khẩu đã được gửi tới email của bạn. Vui lòng xác nhận để tiếp tục.',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors
                                                          .white70, // Màu chữ
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            // Khoảng cách giữa nội dung và nút
                                            Center(
                                              // Để căn giữa nút "OK"
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Đóng hộp thoại
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'OK',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors
                                                        .white, // Màu chữ nút
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF005609),
                                                  // Màu nền nút
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                                  // Padding cho nút
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20), // Bo góc cho nút
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (error) {
                                  // Xử lý lỗi
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Lỗi'),
                                      content: Text(
                                          'Có lỗi xảy ra: ${error.toString()}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                  setState(() {
                                    _isLoading = false; // Bắt đầu loading
                                  });
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.transparent,
                                // Không cần màu viền vì đã có gradient
                                width: 2,
                              ),
                              backgroundColor: Colors.transparent,
                              // Nền trong suốt để hiện gradient
                              foregroundColor: Colors.black87,
                              // Màu chữ
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 32.0),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30.0), // Bo góc nút
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Tiếp tục',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    ));
  }
}
