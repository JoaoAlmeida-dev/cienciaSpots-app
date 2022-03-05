import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/widgets/puzzle/puzzle_piece.dart';
import 'package:logger/logger.dart';

class ImageManipulation {
  static final Logger logger = Logger();

  static Future<Size> getImageSize(Image image) async {
    final Completer<Size> completer = Completer<Size>();

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;

    return imageSize;
  }

  static Future<List<Widget>> splitImagePuzzlePiece({
    required Image image,
    required rows,
    required cols,
    required bringToTop,
    required sendToBack,
  }) async {
    logger.d('started split');
    List<Widget> outputList = [];
    Size imageSize = await getImageSize(image);
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        var puzzlePiece = PuzzlePiece(
          key: GlobalKey(),
          image: image,
          imageSize: imageSize,
          row: x,
          col: y,
          maxRow: rows,
          maxCol: cols,
          bringToTop: bringToTop,
          sendToBack: sendToBack,
        );
        outputList.add(puzzlePiece);
      }
    }
    logger.d('finished split');
    return outputList;
  }

  static Future<List<Widget>> splitImagePuzzlePieceNotDragable({
    required Image image,
    required rows,
    required cols,
    required bringToTop,
    required sendToBack,
  }) async {
    logger.d('started split');
    List<Widget> outputList = [];
    Size imageSize = await getImageSize(image);
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        var puzzlePiece = ClippedPiece(
          image: image,
          row: x,
          col: y,
          maxRow: rows,
          maxCol: cols,
        );
        outputList.add(puzzlePiece);
      }
    }
    logger.d('finished split');
    return outputList;
  }
}