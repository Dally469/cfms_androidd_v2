import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  void checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((updateInfo) {
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate();
      }
    }).catchError((e) {
      if (kDebugMode) {
        print("Update check failed: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In-App Update')),
      body: Center(
        child: ElevatedButton(
          onPressed: checkForUpdate,
          child: const Text('Check for Update'),
        ),
      ),
    );
  }
}
