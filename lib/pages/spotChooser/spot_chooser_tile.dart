import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class ChooseSpotTile extends StatefulWidget {
  const ChooseSpotTile({
    Key? key,
    required this.spot,
    required this.blur,
    required this.chooseSpotCallback,
  }) : super(key: key);

  final Spot spot;
  final double blur;
  final Future<void> Function(Spot spot, BuildContext context)
      chooseSpotCallback;

  @override
  State<ChooseSpotTile> createState() => _ChooseSpotTileState();
}

class _ChooseSpotTileState extends State<ChooseSpotTile> {
  late final Future<double> _completePercentageFuture;
  late bool isSpotPuzzleComplete = widget.spot.puzzleComplete;
  late bool isSpotVisited = widget.spot.visited;
  @override
  void initState() {
    super.initState();
    _completePercentageFuture =
        DatabasePuzzlePieceTable.fetchCompletePercentage(widget.spot.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: InkWell(
        enableFeedback: true,
        //splashColor: Colors.black,
        onTap: () async =>
            await widget.chooseSpotCallback(widget.spot, context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.spot.photoLink,
                    progressIndicatorBuilder: (BuildContext context,
                        String string, DownloadProgress downloadProgress) {
                      return const Center(child: DynamicLoadingWidget());
                    },
                    imageBuilder:
                        (BuildContext context, ImageProvider imageProvider) {
                      return ClipRRect(
                        // borderRadius: BorderRadius.circular(5.0),
                        child: isSpotPuzzleComplete
                            ? Image(
                                image: imageProvider,
                                fit: BoxFit.fitWidth,
                              )
                            : ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: widget.blur,
                                  sigmaY: widget.blur,
                                ),
                                child: Image(
                                  image: imageProvider,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Card(
                        color: IscteTheme.greyColor.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Center(
                            child: isSpotPuzzleComplete || isSpotVisited
                                ? const Icon(
                                    Icons.check,
                                    size: 30,
                                  )
                                : FutureBuilder<double>(
                                    future: _completePercentageFuture,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<double> snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          "${(snapshot.data! * 100).round()}%",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  color: IscteTheme.iscteColor),
                                          maxLines: 1,
                                        );
                                      } else {
                                        return const DynamicLoadingWidget();
                                      }
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.spot.description,
                    softWrap: true,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: IscteTheme.iscteColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
