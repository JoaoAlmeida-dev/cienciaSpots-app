import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/requests/spot_info_request.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/details/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class QRScanResults extends StatelessWidget {
  static const String pageRoute = "QRScanResults";
  QRScanResults({
    Key? key,
    required SpotInfoRequest spotInfoRequest,
  }) : super(key: key) {
    spotID = spotInfoRequest.id ?? 0;
    topicString = spotInfoRequest.title ?? '';
    originalEventsListFuture =
        TimelineTopicService.fetchEvents(topicIds: [spotID]);
    eventsListFutureNotifier = ValueNotifier(originalEventsListFuture);
    yearsListFutureNotifier = ValueNotifier(eventsListFutureNotifier.value.then(
        (List<Event> value) =>
            value.fold<Set<int>>({}, (previousValue, Event element) {
              previousValue.add(element.dateTime.year);
              return previousValue;
            }).toList()));
    yearsListFutureNotifier.value.then((value) {
      LoggerService.instance.debug(value);
      changeYearCallback(value.last);
    });
    yearNotifier = ValueNotifier<int?>(null);
  }

  late int spotID;
  late String topicString;
  late Future<List<Event>> originalEventsListFuture;
  late ValueNotifier<Future<List<Event>>> eventsListFutureNotifier;
  late ValueNotifier<Future<List<int>>> yearsListFutureNotifier;
  late ValueNotifier<int?> yearNotifier;

  Future<void> changeYearCallback(int year) async {
    List<Event> originalEventsList = await originalEventsListFuture;
    eventsListFutureNotifier.value = Future<List<Event>>.value(
        originalEventsList
            .where((element) => element.dateTime.year == year)
            .toList());
    List<int> yearsList = await yearsListFutureNotifier.value;
    yearNotifier.value = year;
    LoggerService.instance.debug(yearNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.qrScanResultScreen(topicString),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: IscteTheme.iscteColor),
        ),
      ),
      body: ValueListenableBuilder<Future<List<int>>>(
          valueListenable: yearsListFutureNotifier,
          builder: (context, yearsListFuture, _) {
            return ValueListenableBuilder<Future<List<Event>>>(
                valueListenable: eventsListFutureNotifier,
                builder: (context, eventsListFuture, _) {
                  return TimelineBody(
                    isFilterTimeline: false,
                    eventsListFuture: eventsListFuture,
                    yearsListFuture: yearsListFuture,
                    handleEventSelection: (eventId, context) =>
                        Navigator.of(context).pushNamed(
                            TimeLineDetailsPage.pageRoute,
                            arguments: eventId),
                    changeYearCallback: changeYearCallback,
                    currentYearNotifier: yearNotifier,
                  );
                });
          })
      /*Center(
        child: ListView.builder(
          itemCount: widget.data.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(widget.data[index].title ?? ""),
              subtitle: Text(widget.data[index].link),
              trailing: widget.data[index].contentIcon,
              onTap: () {
                if (widget.data[index].link.isNotEmpty) {
                  HelperMethods.launchURL(widget.data[index].link);
                }
              },
            );
          },
        ),
      )*/
      ,
    );
  }
}
