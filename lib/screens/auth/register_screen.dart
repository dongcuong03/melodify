import 'package:flutter/material.dart';
import 'package:melodify/models/user_model.dart';
import 'package:melodify/screens/auth/login_screen.dart';
import 'package:melodify/screens/auth/otp_register_screen.dart';
import 'package:melodify/services/auth_service.dart';
import 'package:melodify/utils/validators/auth_validator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;
  String? _fullNameError;
  String? _confirmPasswordError;

  // Biến để theo dõi trạng thái hiển thị mật khẩu
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Biến validator
  final Validator _validator = Validator();

  //Trạng thái loading
  bool _isLoading = false;

  // Hàm thực hiện đăng ký
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Bắt đầu loading
        _emailError = null; // Đặt lại lỗi email
      });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String fullName = _fullNameController.text.trim();

      // Kiểm tra xem email có tồn tại không
      bool emailExists = await AuthService().isEmailExists(email);

      if (emailExists) {
        setState(() {
          _isLoading = false; // Kết thúc loading
          _emailError = 'Email đã tồn tại'; // Cập nhật lỗi email
        });
        return; // Thoát hàm nếu email đã tồn tại
      }


      // Chuyển sang màn hình nhập OTP với email đã nhập
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpRegisterScreen( email: _emailController.text,
          fullName: _fullNameController.text,
          password: _passwordController.text,)),
      );

      setState(() {
        _isLoading = false; // Bắt đầu loading

      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.black87,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 80,
                  ),
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
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Ô nhập tên tài khoản
                          TextFormField(
                            controller: _fullNameController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              // Bật màu nền
                              fillColor: Colors.white.withOpacity(0.1),
                              // Màu nền nhẹ
                              prefixIcon: const Icon(
                                Icons.account_circle,
                                color: Colors.white,
                              ),
                              labelText: 'Tên tài khoản',
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
                                borderSide:
                                    BorderSide.none, // Loại bỏ viền mặc định
                              ),
                              errorText: _fullNameError, // Hiển thị lỗi nếu có
                            ),
                            validator: (value) =>
                                _validator.validateFullName(value),
                          ),
                          const SizedBox(height: 33),
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
                                borderSide:
                                    BorderSide.none, // Loại bỏ viền mặc định
                              ),
                              errorText: _emailError, // Hiển thị lỗi nếu có
                            ),
                            validator: (value) =>
                                _validator.validateEmail(value),
                          ),
                          const SizedBox(height: 33),
                          // Ô nhập Password
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
                                    _isPasswordVisible = !_isPasswordVisible;
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
                                borderSide:
                                    BorderSide.none, // Loại bỏ viền mặc định
                              ),
                              errorText: _passwordError, // Hiển thị lỗi nếu có
                            ),
                            validator: (value) =>
                                _validator.validatePassword(value),
                          ),
                          const SizedBox(height: 33),
                          // Ô nhập xác nhận Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            style: const TextStyle(color: Colors.white),
                            obscureText: !_isConfirmPasswordVisible,
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
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              labelText: 'Xác nhận mật khẩu',
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
                                borderSide:
                                    BorderSide.none, // Loại bỏ viền mặc định
                              ),
                              errorText:
                                  _confirmPasswordError, // Hiển thị lỗi nếu có
                            ),
                            validator: (value) =>
                                _validator.validateConfirmPassword(
                                    value, _passwordController.text.trim()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
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
                        onPressed: _isLoading ? null : _register,
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
                                height: 24.0,
                                width: 24.0,
                                child: CircularProgressIndicator(
                                  color: Colors.black87,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Đăng Ký',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Bạn đã có tài khoản?',
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
                                  builder: (context) => const LoginScreen()));
                        },
                        child: const Text(
                          'Đăng nhập ngay',
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
            ),
          ),
        ),
      ),
    );
  }
}
