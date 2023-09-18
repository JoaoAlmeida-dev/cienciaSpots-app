import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ciencia_spots/models/flickr/flickr_photo.dart';
import 'package:ciencia_spots/services/flickr/flickr_service.dart';
import 'package:ciencia_spots/services/logging/LoggerService.dart';

class FLickrPhotosetService extends FlickrService {
  final StreamController<FlickrPhoto> _controller =
      StreamController<FlickrPhoto>();
  @override
  Stream<FlickrPhoto> get stream => _controller.stream;

  int currentPage = 1;
  final int perPage = 25;
  Future<void> fetch({required String albumID, required int farm}) async {
    assert(!fetching);
    if (fetching) {
      LoggerService.instance.error(
          "Already fetching. Wait for current fetch to finish before making another request!");
    } else {
      try {
        http.Response response = await http
            .get(Uri.parse(
                'https://www.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=${FlickrService.key}&photoset_id=$albumID&user_id=${FlickrService.userID}&page=$currentPage&per_page=$perPage&format=json&nojsoncallback=1'))
            .timeout(const Duration(minutes: 2));
        if (response.statusCode == 200) {
          LoggerService.instance.debug("Started fetching image urls");
          startFetch();
          final jsonResponse = jsonDecode(response.body);
          var photosetPhotosList = jsonResponse["photoset"]["photo"];

          int counter = 0;
          for (var photoEntry in photosetPhotosList) {
            FlickrPhoto flickrPhoto = FlickrPhoto(
              title: photoEntry["title"],
              id: photoEntry["id"],
              server: photoEntry["server"],
              secret: photoEntry["secret"],
              isPrimary: photoEntry["isPrimary"] == 1,
              farm: farm,
            );
            //photosetsInstanceList.add(flickrPhoto);
            counter++;
            LoggerService.instance.debug(flickrPhoto);
            _controller.sink.add(flickrPhoto);
          }
          currentPage++;
          if (counter == 0) {
            _controller.sink.addError(FlickrServiceNoDataException);
          } else if (counter < perPage) {
            _controller.sink.addError(FlickrServiceNoMoreDataException);
          }

          stopFetch();
        } else {
          LoggerService.instance.debug("Error ${response.statusCode}");
          _controller.sink.addError(response.statusCode);
          stopFetch();
          //return [];
        }
      } on Exception catch (e) {
        _controller.sink.addError(e);
        stopFetch();
        //_controller.close();
      }
    }
  }
}
