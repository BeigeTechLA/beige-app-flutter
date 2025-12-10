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
           //  apiUrl = 'https://api-development-ayumanagerpro.help2engg.com/api/';
         https://development-shambhavi.s3.ap-south-1.amazonaws.com/ayumanagerpro/
         imageUrl = 'https://development-shambhavi.s3.ap-south-1.amazonaws.com/ayumanagerpro/'; // Dev URL


        break;
      case 'prod':
        // apiUrl = 'https://api-apm.nextgengurukul.com/api/';
        apiUrl = 'https://api.naturecuretech.com/api/';
        url = 'kicrc.naturecuretech.com';
        branchId = '6';
        clientId = '6';
        imageUrl = 'https://ayumanagerpro.s3.ap-south-1.amazonaws.com/'; // Dev URL

        break;
      default:
        apiUrl = 'https://api-development-ayumanagerpro.help2engg.com/api/';
        url = 'naturecuretech-development.help2engg.com';
        branchId = '6';
        break;
    }
  }
}
