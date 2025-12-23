class AppConfig {
  static String apiUrl = '';
  static String url = '';
  static String imageUrl = '';
  static String branchId = '';
  static String clientId = '';


  static void setEnvironment(String env) {
    switch (env) {
      case 'dev':
            apiUrl = 'http://localhost:3004/api/';
           imageUrl = 'https://development-shambhavi.s3.ap-south-1.amazonaws.com/ayumanagerpro/'; // Dev URL


        break;
      case 'prod':
        // apiUrl = 'https://api-apm.nextgengurukul.com/api/';
        apiUrl = 'https://api.naturecuretech.com/api/';
        imageUrl = 'https://ayumanagerpro.s3.ap-south-1.amazonaws.com/'; // Dev URL

        break;
      default:
        apiUrl = '';
        break;
    }
  }
}
