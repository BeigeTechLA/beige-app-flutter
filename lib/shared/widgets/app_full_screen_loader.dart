// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
//
// import 'package:beige/app/assets.dart';
// import 'package:beige/app/colors.dart';
//
// class AppFullScreenLoader extends StatelessWidget {
//   const AppFullScreenLoader({
//     super.key,
//     this.size = 140,
//     this.scrimOpacity = 0.6,
//   });
//
//   final double size;
//   final double scrimOpacity;
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fill(
//       child: AbsorbPointer(
//         child: ColoredBox(
//           color: AppColors.black.withValues(alpha: scrimOpacity),
//           child: Center(
//             child: Lottie.asset(
//               AppAssets.lottieCircleLoader,
//               width: size,
//               height: size,
//               repeat: true,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
