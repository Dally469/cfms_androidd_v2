import 'package:in_app_update/in_app_update.dart';

class UpdateInfo {
  final bool isAvailable;
  final String currentVersion;
  final String? newVersion;

  UpdateInfo({
    required this.isAvailable,
    required this.currentVersion,
    this.newVersion,
  });
}

class UpdateRepository {
  Future<UpdateInfo> checkForUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      return UpdateInfo(
        isAvailable:
            updateInfo.updateAvailability == UpdateAvailability.updateAvailable,
        currentVersion: updateInfo.availableVersionCode.toString(),
        newVersion: updateInfo.availableVersionCode.toString(),
      );
    } catch (e) {
      return UpdateInfo(
        isAvailable: false,
        currentVersion: 'Unknown',
        newVersion: null,
      );
    }
  }

  Future<bool> performUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
      return true;
    } catch (e) {
      return false;
    }
  }
}
