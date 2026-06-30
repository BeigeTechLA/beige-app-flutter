import 'package:flutter/material.dart';

import 'package:beige/features/home/data/models/home_model.dart';

import 'home_booking_card.dart';
import 'home_empty_booking_card.dart';

/// Your Bookings section body — shows the empty card when [bookings] is
/// empty, otherwise the two-card animated swipe stack driven by the
/// supplied [swipeController].
class HomeBookingsStack extends StatelessWidget {
  final AnimationController swipeController;
  final List<Your_Booking> bookings;
  final int currentIndex;
  final VoidCallback onAdvance;
  final VoidCallback onBookShoot;
  final Function(Your_Booking) onCardTap;

  const HomeBookingsStack({
    super.key,
    required this.swipeController,
    required this.bookings,
    required this.currentIndex,
    required this.onAdvance,
    required this.onBookShoot,
    required this.onCardTap,
  });

  void _advance() {
    if (!swipeController.isAnimating && bookings.isNotEmpty) {
      swipeController.forward().then((_) {
        onAdvance();
        swipeController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return SizedBox(
        height: 160,
        child: HomeEmptyBookingCard(onBookShoot: onBookShoot),
      );
    }

    return GestureDetector(
      onTap: _advance,
      onHorizontalDragEnd: (details) {
        if (swipeController.isAnimating || bookings.isEmpty) {
          return;
        }
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          _advance();
        }
      },
      child: SizedBox(
        height: 408,
        child: AnimatedBuilder(
          animation: swipeController,
          builder: (context, child) {
            // Guard against invalid animation values before calculating transforms.
            double val = swipeController.value;
            if (val.isNaN) val = 0.0;

            // Front card transform.
            double frontSlide = val * 300;
            double frontOpacity = 1 - val;

            // Back card transform.
            double backOffsetX = 20 * (1 - val);
            double backOffsetY = -20 * (1 - val);
            double backScale = 0.96 + (0.04 * val);
            double backRotate = 0.08 * (1 - val);

            // Keep indices within the available bookings list.
            int frontIndex = currentIndex % bookings.length;
            int nextIndex = (currentIndex + 1) % bookings.length;

            return Stack(
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              children: [
                // Back card.
                Transform.translate(
                  offset: Offset(backOffsetX, backOffsetY),
                  child: Transform.rotate(
                    angle: backRotate,
                    child: Transform.scale(
                      scale: backScale,
                      child: Opacity(
                        opacity: 0.5 + (0.5 * val),
                        child: HomeBookingCard(
                          booking: bookings[nextIndex],
                          isBackCard: val < 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Front card.
                Transform.translate(
                  offset: Offset(0, frontSlide),
                  child: Opacity(
                    opacity: frontOpacity,
                    child: HomeBookingCard(
                      booking: bookings[frontIndex],
                      isBackCard: false,
                      onTap: () => onCardTap(bookings[frontIndex]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
