import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:iscte_spots/services/auth/auth_storage_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class PuzzleService {
  static Future<int> _puzzleCompletePost({required int spotID}) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? apiToken = await secureStorage.read(
        key: LoginStorageService.backendApiKeyStorageLocation);

    final request = await client.postUrl(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/puzzle/$spotID'));
    request.headers.set('content-type', 'application/json');
    // var tokenRequestBody = utf8.encode(json.encode({"id": puzzleID}));
    // request.headers.set('Content-Length', tokenRequestBody.length);
    // request.add(tokenRequestBody);
    request.headers.add("Authorization", "Token $apiToken");
    final response = await request.close();
    LoggerService.instance.debug("submitted: ${response.statusCode}");

    dynamic decodedResponse =
        await jsonDecode(await response.transform(utf8.decoder).join());
    LoggerService.instance.debug("decoded response: $decodedResponse");
    if (decodedResponse["points"] != null) {
      return decodedResponse["points"];
    } else {
      return 0;
    }
  }

  static Future<void> PuzzleCompletePost(
      {required BuildContext context,
      required ConfettiController confettiController,
      required Function navigatetoScan,
      required Function navigatetoPuzzle,
      required Spot? spot}) async {
    LoggerService.instance.debug("PuzzleCompletePost");
    if (spot == null) return;

    confettiController.play();
    spot.puzzleComplete = true;
    DatabaseSpotTable.update(spot);
    LoggerService.instance.debug(
        "Send post request with puzzle spot / puzzle id or topic: $spot");
    Future<int> receivedPointsFuture = _puzzleCompletePost(spotID: spot.id);

    await DynamicAlertDialog.showDynamicDialog(
      context: context,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            AppLocalizations.of(context)!.puzzleCompleteDialogTitle,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          FutureBuilder<int>(
              future: receivedPointsFuture,
              builder: (context, receivedPoints) {
                if (receivedPoints.hasData && receivedPoints.data != null) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        size: math.min(MediaQuery.of(context).size.width,
                                MediaQuery.of(context).size.height) *
                            0.2,
                      ),
                      Text(
                        receivedPoints.data.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  );
                } else if (receivedPoints.hasError) {
                  return DynamicErrorWidget(
                    display: AppLocalizations.of(context)!.networkError,
                  );
                } else {
                  return const DynamicLoadingWidget();
                }
              }),
        ],
      ),
      content: Text(AppLocalizations.of(context)!.puzzleCompleteDialog),
      actions: [
        DynamicTextButton(
          onPressed: () async {
            Navigator.of(context).popAndPushNamed(SpotChooserPage.pageRoute);
            navigatetoPuzzle();
          },
          child: Text(
              AppLocalizations.of(context)!.puzzleCompleteDialogCancelButton,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: IscteTheme.iscteColor)),
        ),
        DynamicTextButton(
          onPressed: () async {
            navigatetoScan();
            Navigator.of(context).pop();
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(IscteTheme.iscteColor),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
          ),
          child: Text(
            AppLocalizations.of(context)!.puzzleCompleteDialogConfirmButton,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
