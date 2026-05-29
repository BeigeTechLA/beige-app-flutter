enum Environment { dev, prod }

class Env {
  static late Environment current;
  static late String apiUrl;
  static late String imageUrl;
  static late String stripePublishableKey;

  static void init(Environment environment) {
    current = environment;
    switch (environment) {
      case Environment.dev:
        apiUrl = 'https://mobile.beige.app/api/';
          //apiUrl = 'http://192.168.1.14:3004/api/';
      // apiUrl = "http://10.0.2.2:3004/api/";
        imageUrl = 'https://d1pgtgqp0jru64.cloudfront.net/';
        stripePublishableKey =
            'pk_test_51S5czd54hnPNgHXUq7sunp8uvTDW4ln6aw8Y3bP249JZmx4xuvoIED4mZTuNIkAFcOoCApICfgv9dM4VbbleJo7L00GqNEkj3I';
      case Environment.prod:
        apiUrl = 'https://mobile.prod.beige.app/api/';
        imageUrl = 'https://d2jhn32fsulyac.cloudfront.net/';
        stripePublishableKey = 'PLACE_HOLDER_LIVE_STRIPE_KEY';
    }
  }
}