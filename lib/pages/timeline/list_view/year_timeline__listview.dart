import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline_list_tile.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class YearTimelineListView extends StatefulWidget {
  const YearTimelineListView({
    Key? key,
    required this.hoveredYearIndexNotifier,
  }) : super(key: key);

  final ValueNotifier<int?> hoveredYearIndexNotifier;

  @override
  State<YearTimelineListView> createState() => _YearTimelineListViewState();
}

class _YearTimelineListViewState extends State<YearTimelineListView> {
  final ItemScrollController itemController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    widget.hoveredYearIndexNotifier.addListener(() {
      if (widget.hoveredYearIndexNotifier.value != null) {
        itemController.scrollTo(
            index: widget.hoveredYearIndexNotifier.value!,
            duration: const Duration(milliseconds: 300));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
        valueListenable: widget.hoveredYearIndexNotifier,
        builder: (context, hoverYearIndex, _) {
          return ValueListenableBuilder<int?>(
              valueListenable: TimelineState.selectedYear,
              builder: (context, currentYear, _) {
                return ValueListenableBuilder<Future<List<int>>>(
                  valueListenable: TimelineState.yearsList,
                  builder: (context, yearsListValue, child) =>
                      FutureBuilder<List<int>>(
                          future: yearsListValue,
                          builder: (context, yearsListSnapshot) {
                            if (yearsListSnapshot.connectionState ==
                                    ConnectionState.done &&
                                yearsListSnapshot.hasData) {
                              return ScrollConfiguration(
                                behavior: WebScrollBehaviour(),
                                child: ScrollablePositionedList.builder(
                                    initialScrollIndex: currentYear != null
                                        ? yearsListSnapshot.data!
                                            .indexOf(currentYear)
                                        : yearsListSnapshot.data!.length - 1,
                                    itemScrollController: itemController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: yearsListSnapshot.data!.length,
                                    shrinkWrap: false,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) =>
                                        YearTimelineTile(
                                          year: yearsListSnapshot.data![index],
                                          isSelected: currentYear ==
                                              yearsListSnapshot.data![index],
                                          isHover: hoverYearIndex == index,
                                          isFirst: index == 0,
                                          isLast: index ==
                                              yearsListSnapshot.data!.length -
                                                  1,
                                        )),
                              );
                            } else if (yearsListSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const LoadingWidget();
                            } else if (yearsListSnapshot.hasError) {
                              return NetworkError(
                                  display: yearsListSnapshot.error.toString());
                            } else {
                              return const LoadingWidget();
                            }
                          }),
                );
              });
        });
  }
}
