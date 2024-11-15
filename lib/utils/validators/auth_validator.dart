class Validator {
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tên tài khoản không được để trống';
    }
    if (value.trim().length < 3) {
      return 'Tên tài khoản phải có ít nhất 3 ký tự';
    }
    // Kiểm tra ký tự đặc biệt
    if (RegExp(r'[^a-zA-Z\s]').hasMatch(value)) {
      return 'Tên tài khoản không được chứa ký tự đặc biệt';
    }
    return null;
  }

   String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? validateConfirmPassword(String? confirmPassword, String password) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Xác nhận mật khẩu không được để trống';
    }
    if (confirmPassword != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  String? validateGenreName(String? value) {
    // Kiểm tra nếu tên thể loại rỗng
    if (value == null || value.isEmpty) {
      return "Tên thể loại không được để trống";
    }

    // Kiểm tra nếu tên thể loại chứa ký tự số
    if (RegExp(r'\d').hasMatch(value)) {
      return "Tên thể loại không chứa ký tự số";
    }

    // Kiểm tra độ dài của tên thể loại không quá 30 ký tự
    if (value.length > 30) {
      return "Tên thể loại không được quá 30 ký tự";
    }

    // Nếu tất cả các điều kiện trên đều đúng, trả về null (không có lỗi)
    return null;
  }


}
