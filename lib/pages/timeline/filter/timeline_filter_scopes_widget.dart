import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class ScopesFilterWidget extends StatelessWidget {
  ScopesFilterWidget({
    Key? key,
    this.titleStyle,
    this.textStyle,
    required this.gridCount,
    required this.childAspectRatio,
  }) : super(key: key);

  final int gridCount;
  final double childAspectRatio;
  TextStyle? titleStyle;
  TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    titleStyle = titleStyle ??
        Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: IscteTheme.iscteColor);
    textStyle = textStyle ??
        Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: IscteTheme.iscteColor);
    return SliverList(
      delegate: SliverChildListDelegate([
        buildAvailableEventScopeHeader(),
        buildEventScopesCheckBoxList(),
      ]),
    );
  }

  Future<void> _selectAllScopes() async {
    List<EventScope> allScopes =
        await TimelineState.availableScopesFuture.value;
    TimelineState.operateFilter((params) => params.addAllScope(allScopes));
  }

  Future<void> _clearScopesList() async {
    TimelineState.operateFilter((params) => params.clearScopes());
  }

  Widget buildAvailableEventScopeHeader() {
    return Builder(builder: (context) {
      Text text = Text(
        AppLocalizations.of(context)!.timelineAvailableScopes,
        style: titleStyle,
      );

      DynamicTextButton selectAllBtn = DynamicTextButton(
        style: IscteTheme.greyColor,
        onPressed: _selectAllScopes,
        child: Text(AppLocalizations.of(context)!.timelineSelectAllButton,
            style: titleStyle),
      );

      DynamicTextButton clearAllBtn = DynamicTextButton(
        style: IscteTheme.greyColor,
        onPressed: _clearScopesList,
        child: Text(AppLocalizations.of(context)!.timelineSelectClearButton,
            style: titleStyle),
      );

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          runSpacing: 10,
          spacing: 10,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [text, selectAllBtn, clearAllBtn],
        ),
      );
    });
  }

  Widget buildEventScopesCheckBoxList() {
    return ValueListenableBuilder<Future<List<EventScope>>>(
      valueListenable: TimelineState.availableScopesFuture,
      builder: (context, availableScopesFutureValue, child) =>
          FutureBuilder<List<EventScope>>(
        future: availableScopesFutureValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<EventScope> data = snapshot.data!;
            return GridView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCount,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                return ValueListenableBuilder<TimelineFilterParams>(
                  valueListenable: TimelineState.currentTimelineFilterParams,
                  builder: (context, currentTimelineFilter, child) =>
                      CheckboxListTile(
                    activeColor: IscteTheme.iscteColor,
                    value: currentTimelineFilter.containsScope(data[index]),
                    title: SingleChildScrollView(
                      controller: ScrollController(),
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        data[index].name,
                        style: textStyle,
                      ),
                    ),
                    onChanged: (bool? bool) {
                      if (bool != null) {
                        if (bool) {
                          TimelineState.operateFilter(
                              (params) => params.addScope(data[index]));
                        } else {
                          TimelineState.operateFilter(
                              (params) => params.removeScope(data[index]));
                        }
                      }
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return NetworkError(
                display: AppLocalizations.of(context)!.generalError);
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }
}
