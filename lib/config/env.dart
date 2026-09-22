enum Environment { dev, prod }

class Env {
  static late Environment current;
  static late String apiUrl;
  static late String imageUrl;
  static late String socketUrl;
  static late String stripePublishableKey;

  /// Override via `--dart-define=CHAT_SOCKET_URL=https://...`.
  /// Defaults to API host (without `/api/` suffix).
  static const String _socketOverride = String.fromEnvironment(
    'CHAT_SOCKET_URL',
  );

  /// Chat attachment upload gate. Flip via
  /// `--dart-define=CHAT_ENABLE_ATTACHMENTS=true` once backend ships the
  /// multipart endpoint. UI flow is wired regardless — actual POST is
  /// gated to avoid 404 storms while backend lags.
  static const bool enableChatAttachments = bool.fromEnvironment(
    'CHAT_ENABLE_ATTACHMENTS',
  );

  static void init(Environment environment) {
    current = environment;
    switch (environment) {
      case Environment.dev:
        apiUrl = 'https://mobile.beige.app/api/';
        //apiUrl = 'http://192.168.1.14:3004/api/';
        // apiUrl = "http://10.0.2.2:3004/api/";
        imageUrl = 'https://d1pgtgqp0jru64.cloudfront.net/';
        socketUrl = _socketOverride.isNotEmpty
            ? _socketOverride
            : 'https://api2.dev.beige.app';
        stripePublishableKey =
            'pk_test_51S5czd54hnPNgHXUq7sunp8uvTDW4ln6aw8Y3bP249JZmx4xuvoIED4mZTuNIkAFcOoCApICfgv9dM4VbbleJo7L00GqNEkj3I';
      case Environment.prod:
        apiUrl = 'https://mobile.prod.beige.app/api/';
        imageUrl = 'https://d2jhn32fsulyac.cloudfront.net/';
        socketUrl = _socketOverride.isNotEmpty
            ? _socketOverride
            : 'https://api2.prod.beige.app';
        stripePublishableKey = 'pk_live_51S5czd54hnPNgHXUeZUKeHnojWxW9CoV1cicTHDbn1upsPakN8GtwNgBNORQt3ghPlmJgtbcycT8tw8ctfxRz4a800NeVNgc5u';
    }
  }
}
