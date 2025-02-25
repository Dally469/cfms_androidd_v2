
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class Synchronization{
  static Future<bool> isNetworkAvailable() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.mobile){
      bool result = await InternetConnectionChecker().hasConnection;
      if(result == true) {
        print("Mobile data detected & internet connection");
        return true;
      }else{
        print("No internet : (Reason)");
        return false;
      }
    }else if(connectivityResult == ConnectivityResult.wifi){
      bool result = await InternetConnectionChecker().hasConnection;
      if(result == true) {
        print("WIFI data detected & internet connection");
        return true;
      }else{
        print("No internet : (Reason)");
        return false;
      }
    }else{
      print("Neither Mobilo or wifi detected : (Reason)");
      return false;
    }
  }
}