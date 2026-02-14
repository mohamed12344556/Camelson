import 'dart:developer';

import '../core.dart';

bool isLoggedInUser = false;

class SharedPrefKeys {
  static const String userToken = 'userToken';
  static const String refreshToken = 'refreshToken';
}

//? This is used to check if the user is registered or not
String checkUserWannaRestPasswordOrSignup(
    {required Map<String, dynamic> args}) {
  if (args['isRegistered'] == false) {
    log('user is not registered');
    return "${args["email"]}";
  } else {
    log('user is registered');
    return "${args["value"]}";
  }
}

checkIfLoggedInUser() async {
  String? userToken =
      await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
  if (!userToken.isNullOrEmpty()) {
    isLoggedInUser = true;
  } else {
    isLoggedInUser = false;
  }
}