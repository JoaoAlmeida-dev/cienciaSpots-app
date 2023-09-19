import 'dart:async';
import 'dart:convert';

import 'package:ciencia_spots/services/leaderboard/leaderboard_service.dart';
import 'package:ciencia_spots/widgets/network/error.dart';
import 'package:ciencia_spots/widgets/util/iscte_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//const API_ADDRESS = "http://192.168.1.124";

//const API_ADDRESS_PROD = "https://194.210.120.48";
//const API_ADDRESS_TEST = "http://192.168.1.124";
//const API_ADDRESS_TEST_LATEST_USED = "http://192.168.1.66";

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// FOR ISOLATED TESTING
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeaderBoardPage());
}

class LeaderBoardPage extends StatefulWidget {
  static const pageRoute = "/leaderboard";
  static const IconData icon = Icons.leaderboard;

  const LeaderBoardPage({
    Key? key,
    this.hasAppBar = true,
  }) : super(key: key);

  final bool hasAppBar;

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  late Map<String, dynamic> affiliationMap;

  Future<String> loadAffiliationData() async {
    var jsonText =
        await rootBundle.loadString('Resources/Affiliations/affiliations.json');
    setState(
        () => affiliationMap = json.decode(utf8.decode(jsonText.codeUnits)));
    return 'success';
  }

  static const List<Widget> _pages = <Widget>[
    GlobalLeaderboard(),
    RelativeLeaderboard(),
  ];

  //Page Selection Mechanics
  void _onItemTapped(int index) {
    setState(() {
      _tabController.animateTo(index);
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadAffiliationData();
    _tabController = TabController(length: _pages.length, vsync: this);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: !widget.hasAppBar
          ? null
          : AppBar(
              title: Text(
                AppLocalizations.of(context)!.leaderboardPageTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: IscteTheme.iscteColor),
              ), //AppLocalizations.of(context)!.quizPageTitle)
            ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: _pages,
        ), // _pages[_selectedIndex],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: IscteTheme.appbarRadius,
          topRight: IscteTheme.appbarRadius,
        ),
        child: BottomNavigationBar(
          //type: BottomNavigationBarType.shifting,
          type: BottomNavigationBarType.shifting,
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: IscteTheme.iscteColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          elevation: 8,
          enableFeedback: true,
          iconSize: 30,
          selectedFontSize: 13,
          unselectedFontSize: 10,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          //selectedItemColor: Colors.amber[800],
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.globe),
              backgroundColor: Theme.of(context).primaryColor,
              label: AppLocalizations.of(context)!.leaderboardGlobal,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.location_on),
              backgroundColor: Theme.of(context).primaryColor,
              label: AppLocalizations.of(context)!.leaderboardNearMe,
            ),
          ],
        ),
      ),
    );
  }
}

class GlobalLeaderboard extends StatelessWidget {
  const GlobalLeaderboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          // Container to hold the description
          height: 50,
          child: Center(
            child: Text(AppLocalizations.of(context)!.leaderboardGlobalTitle,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        const Expanded(
          child: LeaderboardList(
            fetchFunction: LeaderboardService.fetchGlobalLeaderboard,
            showRank: true,
          ),
        ),
      ],
    );
  }
}

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
