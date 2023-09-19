import 'dart:convert';

import 'package:ciencia_spots/helper/constants.dart';
import 'package:ciencia_spots/models/timeline/topic.dart';
import 'package:ciencia_spots/services/logging/LoggerService.dart';
import 'package:http/http.dart' as http;

class TimelineTopicService {
  static Future<List<Topic>> fetchTopics({required int eventId}) async {
    try {
      http.Response response = await http.get(
          Uri.parse(
              '${BackEndConstants.API_ADDRESS}/api/events/$eventId/topics'),
          headers: <String, String>{
            'content-type': 'application/json',
          });

      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      //_logger.d(decodedResponse);
      // return response.statusCode;
      List<Topic> topicsList = [];
      for (var entry in decodedResponse) {
        topicsList.add(Topic.fromJson(entry));
      }
      LoggerService.instance.info("fetched topics from event: $eventId");
      return topicsList;
    } catch (e) {
      LoggerService.instance.error(e);
      return Future.error(e);
    }
  }

  static Future<List<Topic>> fetchAllTopics() async {
    try {
      http.Response response = await http.get(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/topics'),
          headers: <String, String>{
            'content-type': 'application/json',
          });

      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      //_logger.d(decodedResponse);
      // return response.statusCode;
      List<Topic> topicsList = [];
      for (var entry in decodedResponse) {
        topicsList.add(Topic.fromJson(entry));
      }
      LoggerService.instance.info("fetched all topics");
      return topicsList;
    } catch (e) {
      LoggerService.instance.error(e);
      return Future.error(e);
    }
  }
}
