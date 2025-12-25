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
            //  apiUrl = 'http://10.0.2.2:3004/api/';
           imageUrl = 'https://beigexmemehouse.s3.eu-north-1.amazonaws.com/beige/'; // Dev URL


        break;
       case 'prod':
        // apiUrl = 'https://api-apm.nextgengurukul.com/api/';
        apiUrl = 'https://api.naturecuretech.com/api/';
        imageUrl = 'https://beigexmemehouse.s3.amazonaws.com/beige/'; // Dev URL

        break;
      default:
        apiUrl = '';
        break;
    }
  }
}
