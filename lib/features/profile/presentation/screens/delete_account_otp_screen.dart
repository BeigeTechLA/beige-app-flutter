import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../account_deletion/presentation/deletion_provider.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/colors.dart';
import '../../../../app/route_names.dart';
import '../../../../app/text_styles.dart';
import '../widgets/delete_flow_widgets.dart';

class DeleteAccountOtpScreen extends ConsumerStatefulWidget {
  const DeleteAccountOtpScreen({super.key});
  @override
  ConsumerState<DeleteAccountOtpScreen> createState() =>
      _DeleteAccountOtpScreenState();
}

class _DeleteAccountOtpScreenState
    extends ConsumerState<DeleteAccountOtpScreen> {
  bool _resent = false;
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focus = List.generate(6, (_) => FocusNode());
  bool get _complete => _controllers.every((c) => c.text.length == 1);

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  void _changed(int index, String value) {
    setState(() {
      if (value.length > 1) {
        // Support pasting/autofilling the entire code from any cell.
        final start = value.length == 6 ? 0 : index;
        final count = value.length.clamp(0, 6 - start);
        for (var i = 0; i < count; i++) {
          _controllers[start + i].text = value[i];
        }
        _focus[(start + count).clamp(0, 5)].requestFocus();
      } else if (value.isNotEmpty && index < 5) {
        _focus[index + 1].requestFocus();
      } else if (value.isEmpty && index > 0) {
        _focus[index - 1].requestFocus();
      }
    });
  }

  Future<void> _resend() async {
    final sent = await ref.read(deletionProvider.notifier).requestOtp();
    if (!mounted) return;
    if (sent) {
      setState(() {
        _resent = true;
        for (final c in _controllers) {
          c.clear();
        }
      });
      _focus.first.requestFocus();
    }
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    final confirmed = await ref
        .read(deletionProvider.notifier)
        .confirm(_controllers.map((c) => c.text).join());
    if (mounted && confirmed) context.goNamed(RouteNames.deleteAccountSuccess);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 20).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DeleteFlowBack(),
                      const SizedBox(height: 8),
                      Text(
                        'Verify Your Identity',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          text:
                              "For your security, please verify your identity before submitting your account deletion request. We've sent a verification code to your registered ",
                          children: [
                            TextSpan(
                              text: 'email address.',
                              style: AppTextStyles.bodyMediumStrong.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        style: DeleteFlowStyle.body,
                      ),
                      const SizedBox(height: 26),
                      AutofillGroup(
                        child: Row(
                          spacing: 7,
                          children: List.generate(
                            6,
                            (index) => Expanded(
                              child: Focus(
                                onKeyEvent: (_, event) {
                                  if (event is KeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.backspace &&
                                      _controllers[index].text.isEmpty &&
                                      index > 0) {
                                    _focus[index - 1].requestFocus();
                                    return KeyEventResult.handled;
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: TextField(
                                  key: ValueKey('deletion-otp-$index'),
                                  controller: _controllers[index],
                                  focusNode: _focus[index],
                                  autofocus: index == 0,
                                  cursorColor: AppColors.primary,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  autofillHints: index == 0
                                      ? const [AutofillHints.oneTimeCode]
                                      : null,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.white,
                                    height: 1.25,
                                  ),
                                  decoration: InputDecoration(
                                    semanticCounterText:
                                        'Digit ${index + 1} of 6',
                                    filled: _controllers[index].text.isNotEmpty,
                                    fillColor: DeleteFlowStyle.filledInput,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 17,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _controllers[index].text.isEmpty
                                            ? AppColors.white60
                                            : AppColors.primary,
                                        width: .5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: .5,
                                      ),
                                    ),
                                  ),
                                  onTap: () => _controllers[index].selection =
                                      TextSelection(
                                        baseOffset: 0,
                                        extentOffset:
                                            _controllers[index].text.length,
                                      ),
                                  onChanged: (value) => _changed(index, value),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _resent
                            ? 'A new verification code has been sent.'
                            : 'Enter the latest code sent to your registered email.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Spacer(),
                      Center(
                        child: TextButton(
                          onPressed: ref.watch(deletionProvider).busy
                              ? null
                              : _resend,
                          child: Text(
                            'Resend OTP',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      DeleteFlowButton(
                        label: ref.watch(deletionProvider).busy
                            ? 'Please wait…'
                            : 'Verify & Delete my Account',
                        onPressed:
                            _complete &&
                                !ref.watch(deletionProvider).busy &&
                                ref.watch(deletionProvider).otpSent
                            ? _confirm
                            : null,
                      ),
                      if (ref.watch(deletionProvider).error
                          case final String error)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(error, style: DeleteFlowStyle.body),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
