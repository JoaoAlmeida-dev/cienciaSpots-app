import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/pages/leaderboard/relative_leaderboard.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

import 'global_leaderboard.dart';

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
