import 'package:flutter/material.dart';
import 'package:beige/utility/ColorCode.dart';

class RecommendedForYou extends StatelessWidget {
  const RecommendedForYou({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recommended For You",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.filter_alt_outlined,
                      color: Colors.white.withOpacity(0.7)),
                ],
              ),

              const SizedBox(height: 16),

              /// 🔥 LIST
              Expanded(
                child: ListView(
                  children: const [
                    RecommendedCard(
                      image: "assets/images/home2.png",
                      name: "Angela Kia",
                      role: "Videography Specialist",
                      rating: "4.5 (120)",
                      price: "\$450/Hr",
                    ),
                    SizedBox(height: 16),
                    RecommendedCard(
                      image: "assets/images/home2.png",
                      name: "Lucas Bennett",
                      role: "Photographer Specialist",
                      rating: "4.2 (400)",
                      price: "\$250/Hr",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔥 CARD WIDGET
class RecommendedCard extends StatelessWidget {
  final String image;
  final String name;
  final String role;
  final String rating;
  final String price;

  const RecommendedCard({
    super.key,
    required this.image,
    required this.name,
    required this.role,
    required this.rating,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [

          /// 🔹 IMAGE
          Positioned.fill(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 DARK OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          /// 🔹 ACTIVE DOT
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.green,
                ),
                SizedBox(width: 6),
                Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 HEART
          Positioned(
            top: 12,
            right: 12,
            child: Icon(
              Icons.favorite_border,
              color: Colors.white,
            ),
          ),

          /// 🔹 DETAILS
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ⭐ RATING
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// NAME
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                /// ROLE
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                /// PRICE BUTTON
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorCode.kButtonColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "From $price",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
