// ignore: file_names
class Utils {
  static String getUserName(String email) {
    return "Live:${email.split('@')[0]}";
  }

  static String getInitials(String name) {
    List<String> nameSplit = name.split("");
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[0][0];

    return firstNameInitial + lastNameInitial;
  }
}
