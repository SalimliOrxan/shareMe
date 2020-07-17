
bool validateUsername(String username){
  return username != null && username.trim().isNotEmpty;
}

bool validatePassword(String password){
  RegExp reg = new RegExp(
    "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}",
    caseSensitive: true,
    multiLine: false,
  );
  return password != null && password.trim().isNotEmpty && reg.hasMatch(password);
}

bool validatePasswordAgain(String password1, String password2){
  return password1 == password2;
}

bool validateEmail(String email){
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}