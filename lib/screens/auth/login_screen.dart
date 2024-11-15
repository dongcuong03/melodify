import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:melodify/providers/firebase_auth_provider.dart';
import 'package:melodify/screens/auth/forgot_password_screen.dart';
import 'package:melodify/screens/auth/register_screen.dart';
import 'package:melodify/screens/user/user_main_screen.dart';
import 'package:melodify/utils/validators/auth_validator.dart';
import 'package:provider/provider.dart';

import '../admin/admin_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;
  final Validator _validator = Validator();

//Biến theo dõi trang thái load khi đăng nhập bằng email, password
  bool _isLoading = false;

  // Biến theo dõi trạng thái loading cho Google sign in
  bool _isGoogleLoading = false;

  // Biến để theo dõi trạng thái hiển thị mật khẩu
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
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
                        height: 100,
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
                        height: 80,
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
                              const SizedBox(height: 33),
                              // Ô nhập mật khẩu
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: !_isPasswordVisible,
                                obscuringCharacter: '●',
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  filled: true,
                                  // Bật màu nền
                                  fillColor: Colors.white.withOpacity(0.1),
                                  // Màu nền nhẹ
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Colors.white,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  labelText: 'Mật khẩu',
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
                                  errorText:
                                      _passwordError, // Hiển thị lỗi nếu có
                                ),
                                validator: (value) =>
                                    _validator.validatePassword(value),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 33.0, left: 16.0, right: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen()));
                              },
                              child: const Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF005609),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 27.0),
                        child: Container(
                          width: 230.0,
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
                                  _passwordError = null;
                                });

                                // Gọi phương thức đăng nhập
                                await authProvider.loginWithEmail(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                if (authProvider.errorMessage == null) {
                                  // Kiểm tra vai trò của người dùng sau khi đăng nhập thành công
                                  String? role =
                                      await authProvider.checkUserRole(
                                          _emailController.text.trim());
                                  if (role == 'admin') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdminMainScreen(
                                              user: authProvider.user)),
                                    );
                                  } else if (role == 'user') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserMainScreen(
                                              user: authProvider.user)),
                                    );
                                  }
                                } else {
                                  // Phân loại lỗi
                                  if (authProvider.errorMessage!
                                      .contains('Email')) {
                                    setState(() {
                                      _emailError = authProvider.errorMessage;
                                      _passwordError = null;
                                    });
                                  } else if (authProvider.errorMessage!
                                      .contains('Mật khẩu')) {
                                    setState(() {
                                      _emailError = null;
                                      _passwordError =
                                          authProvider.errorMessage;
                                    });
                                  }
                                }
                                // Kết thúc quá trình đăng nhập
                                setState(() {
                                  _isLoading = false;
                                });
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
                                    'Đăng Nhập',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 33.0, left: 16.0, right: 16.0, bottom: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white30, // Màu của đường kẻ
                                thickness: 1.5, // Độ dày của đường kẻ
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Hoặc',
                                style: TextStyle(
                                  color: Colors.white30, // Màu chữ
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white30, // Màu của đường kẻ
                                thickness: 1.5, // Độ dày của đường kẻ
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          OutlinedButton(
                            onPressed: () async {
                              setState(() {
                                _isGoogleLoading = true; // Bắt đầu loading
                              });

                              // Gọi hàm signInWithGoogle() và đón lỗi nếu có
                              String? error = await authProvider.signInWithGoogle();

                              if  (authProvider.user != null) {
                                // Nếu không có lỗi, chuyển tới màn hình chính
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserMainScreen(user: authProvider.user),
                                  ),
                                );
                              } else if (error != null){
                                // Nếu có lỗi, hiển thị thông báo lỗi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                    duration: const Duration(seconds: 6),
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }

                              setState(() {
                                _isGoogleLoading = false; // Kết thúc loading
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey), // Đường viền
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Bo tròn các góc
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Khoảng cách bên trong nút
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/google2.png',
                                  width: 26,
                                  height: 26,
                                ),
                                SizedBox(width: 12), // Khoảng cách giữa icon và text
                                const Text(
                                  'Tiếp tục với Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          )

                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Bạn chưa có tài khoản?',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen()));
                            },
                            child: const Text(
                              'Đăng ký ngay',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005609),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
        // Hiệu ứng loading
        if (_isGoogleLoading)
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
    ));
  }
}
