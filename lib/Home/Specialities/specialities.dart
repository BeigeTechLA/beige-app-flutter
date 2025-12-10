import 'package:flutter/material.dart';

class Specialities extends StatefulWidget {
  const Specialities({super.key});

  @override
  State<Specialities> createState() => _SpecialitiesState();
}

class _SpecialitiesState extends State<Specialities> {
  // ---- DATA LIST ----
  final List<Map<String, String>> items = [
    {"title": "Events &\nParties", "icon": "assets/images/home3.png"},
    {"title": "Creative &\nMedia", "icon": "assets/images/home3.png"},
    {"title": "Travel &\nOutdoors", "icon": "assets/images/home3.png"},
    {"title": "Drone &\nAerial", "icon": "assets/images/home3.png"},
    {"title": "Sports &\nAction", "icon": "assets/images/home3.png"},
    {"title": "Personal\nShoots", "icon": "assets/images/home3.png"},
    {"title": "Hospitality &\nInteriors", "icon": "assets/images/home3.png"},
    {"title": "Education &\nInstitutions", "icon": "assets/images/home3.png"},
    {"title": "Business &\nProfessional", "icon": "assets/images/home3.png"},
    {"title": "Commercial\nShoots", "icon": "assets/images/home3.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 15),

              Text(
                "Specialties",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

               SizedBox(height: 15),

              // GRID VIEW (NO BLUE BORDER)
              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [

                            // 🔥 BACKGROUND IMAGE
                            Positioned.fill(
                              child: Image.asset(
                                items[index]["icon"]!,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // 🔥 TOP-LEFT TEXT
                /*            Positioned(
                              top: 12,
                              left: 12,
                              child: Text(
                                items[index]["title"]!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
