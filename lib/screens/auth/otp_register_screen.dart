import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melodify/screens/auth/login_screen.dart';
import 'package:melodify/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/firebase_auth_provider.dart';

class OtpRegisterScreen extends StatefulWidget {
  final String email;
  final String fullName;
  final String password;

  const OtpRegisterScreen({
    Key? key,
    required this.email,
    required this.fullName,
    required this.password,
  }) : super(key: key);

  @override
  State<OtpRegisterScreen> createState() => _OtpRegisterScreenState();
}

class _OtpRegisterScreenState extends State<OtpRegisterScreen> {
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());
  final List<String> _otpValues = List.filled(5, '');
  int _remainingTime = 300; // 2 phút
  Timer? _inactivityTimer; // Timer cho thời gian không hoạt động
  Timer? _timer;
  bool _isLoading = false; // Biến trạng thái loading
  bool _isOtpSent = false; // Biến theo dõi xem OTP đã được gửi hay chưa

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Gửi mã OTP ngay khi mở trang
    _startTimer();
    _startInactivityTimer();
  }

  void _sendOtp() async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });

    await Provider.of<FirebaseAuthProvider>(context, listen: false)
        .sendOtp(widget.email);

    setState(() {
      _isLoading = false; // Kết thúc loading
      _isOtpSent = true; // Đánh dấu OTP đã được gửi
    });
  }

  // Phương thức khởi tạo timer cho thời gian không hoạt động
  void _startInactivityTimer() {
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick >= 420) {
        // 7 phút
        // Điều hướng về trang đăng ký
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RegisterScreen()), // Thay đổi YourRegisterScreen bằng tên trang đăng ký của bạn
        );
        _inactivityTimer?.cancel();
      }
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel(); // Hủy timer cũ
    _startInactivityTimer(); // Bắt đầu lại timer
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _deleteOtp();
      }
    });
  }

  Future<void> _deleteOtp() async {
    // Gọi hàm xóa OTP từ provider
    await Provider.of<FirebaseAuthProvider>(context, listen: false)
        .deleteOtp(widget.email);
  }

  void _handleKeyPress(String value, int index) {
    _resetInactivityTimer(); // Reset timer khi có tương tác
    if (value.isNotEmpty) {
      setState(() {
        _otpValues[index] = value; // Cập nhật giá trị OTP trong setState
        print("Giá trị OTP tại index $index: ${_otpValues[index]}");
      });

      if (index < 4) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      }
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });

    String otp = _otpValues.join('');
    print('Giá trị OTP sau khi ghép: $otp');
    // Gọi phương thức verifyOtp từ provider
    bool isValid =
        await Provider.of<FirebaseAuthProvider>(context, listen: false)
            .verifyOtp(widget.email, otp);

    if (isValid) {
      print('Mã OTP đã nhập: $otp - Xác thực thành công!');

      // Gọi hàm đăng ký khi OTP hợp lệ
      await Provider.of<FirebaseAuthProvider>(context, listen: false)
          .registerWithEmail(widget.email, widget.password, widget.fullName);

      setState(() {
        _isLoading = false; // Kết thúc loading
      });

      // Điều hướng đến trang đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Đăng ký thành công!',
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
      setState(() {
        _isLoading = false; // Kết thúc loading
      });
      print('Mã OTP không hợp lệ.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Mã xác nhận không hợp lệ',
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
    }
  }

  void _resendOtp() {
    // Logic gửi lại mã OTP
    setState(() {
      _remainingTime = 300; // Đặt lại thời gian còn lại
      _isOtpSent = false; // Đánh dấu OTP chưa được gửi
      _otpValues.fillRange(0, _otpValues.length, ''); // Reset các ô nhập
      for (var focusNode in _focusNodes) {
        focusNode.unfocus(); // Bỏ focus khỏi tất cả các ô nhập
      }
    });
    _sendOtp(); // Gửi lại mã OTP
    _startTimer(); // Bắt đầu lại đồng hồ đếm ngược
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inactivityTimer?.cancel(); // Hủy timer không hoạt động

    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _timer?.cancel();
          _inactivityTimer?.cancel();
          await _deleteOtp();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
          return false; // Prevent the back navigation
        },
        child: Scaffold(
          body: Stack(
            children: [
              Center(
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.black87,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 120),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Melodify',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              CircleAvatar(
                                  radius: 10, backgroundColor: Color(0x80005609)),
                              SizedBox(width: 8),
                              CircleAvatar(
                                  radius: 15, backgroundColor: Color(0xBF005609)),
                              SizedBox(width: 8),
                              CircleAvatar(
                                  radius: 25, backgroundColor: Color(0xff005609)),
                            ],
                          ),
                          const SizedBox(height: 70),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Vui lòng nhập mã xác nhận đã được gửi tới email ${widget.email}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                const SizedBox(height: 50),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(5, (index) {
                                    return SizedBox(
                                      width: 40,
                                      child: TextField(
                                        focusNode: _focusNodes[index],
                                        onChanged: (value) {
                                          _handleKeyPress(value, index);
                                        },
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        cursorColor: Colors.orange,
                                        cursorWidth: 2.0,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        maxLength: 1,

                                        // Bỏ số bên dưới ô
                                        style:
                                        const TextStyle(color: Colors.orange),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          // Tắt hiển thị số lượng ký tự
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors
                                                    .white), // Màu viền khi không focus
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors
                                                    .orange), // Màu viền khi focus
                                          ),
                                          hintStyle: TextStyle(color: Colors.white),
                                          hintText: '_', // Placeholder
                                        ),
                                        onSubmitted: (value) {
                                          if (value.isNotEmpty) {
                                            _handleKeyPress(value, index);
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Thời gian còn lại: ",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                    Text(
                                      "${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.orange),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                TextButton(
                                  onPressed: _resendOtp,
                                  child: const Text("Gửi lại mã OTP",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF005609))),
                                ),
                                const SizedBox(height: 40),
                                // Hiện hiệu ứng loading giữa trang
                                if (!_isLoading) // Chỉ hiển thị nút xác nhận khi không loading
                                  Container(
                                    width: 230.0,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF005609), Colors.white],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: OutlinedButton(
                                      onPressed:
                                      _remainingTime > 0 ? _verifyOtp : null,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.transparent,
                                          width: 2,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14.0, horizontal: 32.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Xác nhận mã OTP',
                                        style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Lớp mờ và spinner loading
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white, // Màu nền trắng phủ kín
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )
    );
  }
}
