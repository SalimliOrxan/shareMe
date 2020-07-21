class UpdateCredential {

  String email;
  String currentPassword;
  String newPassword;
  String newPasswordAgain;

  UpdateCredential({
    this.email,
    this.currentPassword,
    this.newPassword,
    this.newPasswordAgain
  });
}