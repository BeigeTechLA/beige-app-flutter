import 'package:beige/features/booking/presentation/providers/review_v2_notifier.dart';
import 'package:beige/features/booking/presentation/screens/review_confirm_v2_screen.dart';
import 'package:beige/features/profile/presentation/providers/profile_notifier.dart';
import 'package:beige/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Profile extends ProfileNotifier {
  _Profile(this.initial);
  final ProfileState initial;
  @override
  ProfileState build() => initial;
  void update(Map<String, dynamic> profile) {
    state = ProfileState(status: ProfileStatus.loaded, profile: profile);
  }
}

class _Review extends ReviewV2Notifier {
  _Review(this.contact);
  final Map<String, dynamic> contact;
  @override
  ReviewV2State build() => ReviewV2State(
    status: ReviewV2Status.loaded,
    review: {'contact': contact},
  );
  @override
  Future<void> loadReview({
    required int bookingId,
    required List<Map<String, dynamic>> addOnItems,
  }) async {}
}

Widget _host(_Profile profile, {Map<String, dynamic> contact = const {}}) =>
    ProviderScope(
      overrides: [
        profileNotifierProvider.overrideWith(() => profile),
        reviewV2NotifierProvider.overrideWith(() => _Review(contact)),
      ],
      child: const MaterialApp(home: ReviewConfirmV2Screen(bookingId: 1)),
    );

TextEditingController _field(WidgetTester tester, String label) => tester
    .widget<AppTextField>(
      find.byWidgetPredicate(
        (widget) => widget is AppTextField && widget.label == label,
      ),
    )
    .controller!;

void main() {
  testWidgets(
    'prefills profile contact details using legacy phone formatting',
    (tester) async {
      await tester.pumpWidget(
        _host(
          _Profile(
            const ProfileState(
              status: ProfileStatus.loaded,
              profile: {
                'full_name': ' Alex Smith ',
                'email': ' alex@example.com ',
                'contact_number': '+1 (415) 555-0123',
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect(_field(tester, 'Full Name*').text, 'Alex Smith');
      expect(_field(tester, 'Email ID*').text, 'alex@example.com');
      expect(_field(tester, 'Phone Number*').text, '4155550123');
    },
  );

  testWidgets('late profile fills empty fields without replacing user input', (
    tester,
  ) async {
    final profile = _Profile(const ProfileState(status: ProfileStatus.loading));
    await tester.pumpWidget(_host(profile));
    await tester.pump();
    _field(tester, 'Full Name*').text = 'Booking contact';
    profile.update({
      'name': 'Profile name',
      'email': 'profile@example.com',
      'mobile': '4155550123',
    });
    await tester.pump();
    await tester.pump();
    expect(_field(tester, 'Full Name*').text, 'Booking contact');
    expect(_field(tester, 'Email ID*').text, 'profile@example.com');
    expect(_field(tester, 'Phone Number*').text, '4155550123');
  });

  testWidgets('uses saved booking contact when profile is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _Profile(const ProfileState(status: ProfileStatus.error)),
        contact: {
          'full_name': 'Saved contact',
          'email': 'saved@example.com',
          'phone': '4155550123',
        },
      ),
    );
    await tester.pump();
    expect(_field(tester, 'Full Name*').text, 'Saved contact');
    expect(_field(tester, 'Email ID*').text, 'saved@example.com');
    expect(_field(tester, 'Phone Number*').text, '4155550123');
  });
}
