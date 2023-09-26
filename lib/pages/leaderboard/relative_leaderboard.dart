import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/services/leaderboard/leaderboard_service.dart';

import 'leaderboard_list.dart';

class RelativeLeaderboard extends StatelessWidget {
  const RelativeLeaderboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          // Container to hold the description
          height: 50,
          child: Center(
            child: Text(AppLocalizations.of(context)!.leaderboardNearMeTitle,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        const Expanded(
            child: LeaderboardList(
          fetchFunction: LeaderboardService.fetchRelativeLeaderboard,
          showRank: false,
        )),
      ],
    );
  }
}
