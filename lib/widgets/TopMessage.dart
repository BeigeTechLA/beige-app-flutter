import 'dart:ui';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

class TopMessage {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [

          /// 🔹 BLUR BACKGROUND
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 1,
                  sigmaY: 1,

              ),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),

          /// 🔹 TOP MESSAGE
          Positioned(
            top: 110, // 🔥 thoda niche
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A0000),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [

                    const Icon(
                      Icons.block,
                      color: ColorCode.red,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontFamily: "Outfit",
                          color: ColorCode.white,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        overlayEntry.remove();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}