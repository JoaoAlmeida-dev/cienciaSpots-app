import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class LeaderboardList extends StatefulWidget {
  final Future<List<dynamic>> Function(BuildContext context) fetchFunction;
  final bool showRank;
  //Used to highlight the user in the "near me" leaderboard page

  const LeaderboardList({
    Key? key,
    required this.fetchFunction,
    required this.showRank,
  }) : super(key: key);

  @override
  LeaderboardListState createState() => LeaderboardListState();
}

class LeaderboardListState extends State<LeaderboardList> {
  late Future<List<dynamic>> futureLeaderboard;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureLeaderboard = widget.fetchFunction(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureLeaderboard,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          var items = snapshot.data as List<dynamic>;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                if (!isLoading) {
                  futureLeaderboard = widget.fetchFunction(context);
                }
              });
            },
            child: items.isEmpty
                ? const Center(child: Text("Não foram encontrados resultados"))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      bool isMainUser = items[index]["is_user"] ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Card(
                          child: ListTile(
                            title: Text(items[index]["name"].toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: isMainUser
                                            ? IscteTheme.iscteColor
                                            : null)),
                            subtitle: Text(
                                "${AppLocalizations.of(context)!.leaderboardPoints}: ${items[index]["points"]} "),
                            minVerticalPadding: 10.0,
                            trailing: widget.showRank
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                        if (index == 0)
                                          Image.asset(
                                              "Resources/Img/LeaderBoardIcons/gold_medal.png")
                                        else if (index == 1)
                                          Image.asset(
                                              "Resources/Img/LeaderBoardIcons/silver_medal.png")
                                        else if (index == 2)
                                          Image.asset(
                                              "Resources/Img/LeaderBoardIcons/bronze_medal.png"),
                                        const SizedBox(width: 10),
                                        Text("#${index + 1}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                      ])
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
          );
        } else if (snapshot.connectionState != ConnectionState.done) {
          children = const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator.adaptive(),
            ),
          ];
        } else if (snapshot.hasError) {
          children = [DynamicErrorWidget.networkError(context: context)];
        } else {
          children = const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator.adaptive(),
            ),
          ];
        }
        return GestureDetector(
          onTap: () {
            setState(() {
              if (!isLoading) {
                futureLeaderboard = widget.fetchFunction(context);
              }
            });
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
