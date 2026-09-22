import 'package:flutter/material.dart';

import 'package:beige/app/radii.dart';

/// Studios carousel item — full-bleed photo card (background image only).
class HomeStudioCard extends StatelessWidget {
  final Map<String, String> data;

  const HomeStudioCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: AppRadii.roundAll,
            child: Image.asset(
              data['image']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
