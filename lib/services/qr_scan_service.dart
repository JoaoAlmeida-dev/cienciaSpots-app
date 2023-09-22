import 'dart:convert';
import 'dart:io';

import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/requests/spot_info_request.dart';
import 'package:iscte_spots/services/auth/exceptions.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'auth/auth_storage_service.dart';
import 'auth/login_service.dart';

class QuizLevelNotAchieved implements Exception {}

class QRScanService {
  static Future<SpotInfoRequest> spotInfoRequest(
      {required BuildContext context, required Barcode barcode}) async {
    LoggerService.instance
        .debug("started request at ${DateTime.now()}\t${barcode.rawValue}");
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? apiToken = await secureStorage.read(
        key: LoginStorageService.backendApiKeyStorageLocation);
    if (apiToken == null) {
      throw LoginException();
    }
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      final HttpClientRequest request;

      request = await client.getUrl(Uri.parse(
          '${BackEndConstants.API_ADDRESS}/api/spots/${barcode.rawValue}?app=true'));

      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();
      if (response.statusCode == 403) {
        LoginService.logOut(context);
        throw LoginException();
      } else if (response.statusCode == 404) {
        throw InvalidQRException();
      } else {
        var responseDecoded =
            jsonDecode(await response.transform(utf8.decoder).join());

        LoggerService.instance.debug(responseDecoded);

        if (responseDecoded["id"] != null && responseDecoded["title"] != null) {
          if ((responseDecoded["title"] as String).isNotEmpty) {
            return SpotInfoRequest(
              id: responseDecoded["id"],
              title: responseDecoded["title"],
              visited: responseDecoded["visited"] ?? false,
            );
          } else {
            LoggerService.instance.error("No title in spotInfoRequest");
          }
        }
        throw Exception("Bad response");
      }
    } on SocketException {
      LoggerService.instance.error("Socket Exception");
      rethrow;
    } catch (e) {
      LoggerService.instance.error("$e\n${barcode.rawValue}");
      rethrow;
    }
  }

  // static Future<TopicRequest> topicRequest(
  //     {required BuildContext context, required int topicID}) async {
  //   const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  //   String? apiToken = await secureStorage.read(
  //       key: LoginStorageService.backendApiKeyStorageLocation);
  //   if (apiToken == null) {
  //     throw LoginException();
  //   }
  //
  //   HttpClient client = HttpClient();
  //   client.badCertificateCallback =
  //       ((X509Certificate cert, String host, int port) => true);
  //   final HttpClientRequest request = await client.getUrl(
  //       Uri.parse('${BackEndConstants.API_ADDRESS}/api/topics/$topicID'));
  //
  //   request.headers.add("Authorization", "Token $apiToken");
  //
  //   final response = await request.close();
  //   var responseDecoded =
  //       jsonDecode(await response.transform(utf8.decoder).join());
  //
  //   LoggerService.instance.debug(responseDecoded);
  //
  //   if (response.statusCode == 403) {
  //     throw LoginException();
  //   } else if (response.statusCode == 404) {
  //     throw InvalidQRException();
  //   } else {
  //     try {
  //       if (responseDecoded["title"] != null &&
  //           responseDecoded["content"] != null) {
  //         var responseContentList = responseDecoded["content"];
  //         LoggerService.instance.debug(responseContentList);
  //         final List<Content> contentList = [];
  //         for (var rawContent in responseContentList) {
  //           contentList.add(Content.fromJson(rawContent));
  //         }
  //         return TopicRequest(
  //           title: responseDecoded["title"],
  //           contentList: contentList,
  //         );
  //       } else if (responseDecoded["status"] != null) {
  //         if (responseDecoded["status"] ==
  //             "The quiz for this level was not completed") {
  //           throw QuizLevelNotAchieved();
  //         }
  //       }
  //       throw Exception("Response without title or content keys");
  //     } on SocketException {
  //       LoggerService.instance.error("Socket Exception");
  //       rethrow;
  //     } catch (e) {
  //       LoggerService.instance.error(e);
  //       rethrow;
  //     }
  //   }
  // }
}
