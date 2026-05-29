import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  // ✨ فحص الاتصال بالإنترنت
  static Future<bool> hasConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    // Return true if any result is not 'none'
    return connectivityResults.isNotEmpty &&
           !connectivityResults.contains(ConnectivityResult.none);
  }

  // ✨ الاستماع للتغييرات في الاتصال
  static Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged.map((results) {
      return results.isNotEmpty &&
             !results.contains(ConnectivityResult.none);
    });
  }
}
