import 'dart:io';

import 'package:get_cli/cli_config/cli_config.dart';
import 'package:get_cli/functions/version/check_dev_version.dart';
import 'package:get_cli/functions/version/print_get_cli.dart';
import 'package:version/version.dart';

import '../../common/utils/logger/LogUtils.dart';
import '../../common/utils/pub_dev/pub_dev_api.dart';
import '../../common/utils/pubspec/pubspec_lock.dart';

void checkForUpdate() async {
  if (!await CliConfig.updateIsCheckingToday()) {
    if (!isDevVersion()) {
      await PubDevApi.getLatestVersionFromPackage('get_cli')
          .then((versionInPubDev) async {
        await PubspecLock.getVersionCli(disableLog: true)
            .then((versionInstalled) async {
          if (versionInstalled == null) exit(2);

          final v1 = Version.parse(versionInPubDev);
          final v2 = Version.parse(versionInstalled);
          final needsUpdate = v1.compareTo(v2);
          // needs update.
          if (needsUpdate == 1) {
            LogService.info('''There\'s an update available!
Current installed version: $versionInstalled         
''');
            //await versionCommand();
            printGetCli();
            final codeSample = LogService.code('get update');
            LogService.info('''New version available: $versionInPubDev
Please, run $codeSample''', false, true);
          }
        });
      });
      await CliConfig.setUpdateCheckToday();
    }
  }
}
