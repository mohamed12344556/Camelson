// import 'dart:developer';

// import 'package:flutter/material.dart';

// import '../../../../core/core.dart';
// import '../../../../generated/l10n.dart';
// import '../widgets/continue_with.dart';
// import '../widgets/custom_social_button.dart';
// import 'login_view.dart';

// class SigUpSigninView extends StatelessWidget {
//   const SigUpSigninView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Robot Image
//                 Image.asset(Assets.robot, height: 350),
//                 const SizedBox(height: 32),
//                 // Welcome Text
//                 Text(
//                   S.of(context).welcome_messagewelcome_message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 16, color: Colors.black87),
//                 ),
//                 const SizedBox(height: 32),
//                 // Sign In Button
//                 CustomButton(
//                   onPressed: () {
//                     context.pushNamed(AppRoutes.loginView);
//                   },
//                   text: S.of(context).login_button,
//                   textColor: Colors.white,
//                   backgroundColor: Colors.blue,
//                   isLoading: false,
//                   borderRadius: 8,
//                 ),
//                 const SizedBox(height: 12),
//                 // Sign Up Button
//                 CustomButton(
//                   onPressed: () {
//                     context.pushNamed(AppRoutes.registerView);
//                   },
//                   text: S.of(context).signup_button,
//                   textColor: Colors.blue,
//                   backgroundColor: Colors.grey[100],
//                   isLoading: false,
//                   borderRadius: 8,
//                 ),
//                 const SizedBox(height: 24),
//                 // Or continue with text
//                 const ContinueWith(),
//                 const SizedBox(height: 24),
//                 // Social Login Buttons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     CustomSocialButton(
//                       imagePath: Assets.google,
//                       onTap: () {
//                         signIn(context);
//                       },
//                     ),
//                     CustomSocialButton(
//                       imagePath: Assets.facebook,
//                       onTap: () {
//                         log('Facebook');
//                       },
//                     ),
//                     CustomSocialButton(
//                       imagePath: Assets.apple,
//                       onTap: () {
//                         log('Apple');
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
