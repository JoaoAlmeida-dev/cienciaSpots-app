import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/nav_drawer/drawer.dart';
import 'package:iscte_spots/pages/home/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/pages/home/widgets/sucess_scan_widget.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/quiz/quiz_list_menu.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_icon_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

import '../timeline/feedback_form.dart';
import 'widgets/completed_challenge_widget.dart';

class HomePage extends StatefulWidget {
  static const pageRoute = "/home";

  HomePage({Key? key}) : super(key: key);

  final int scanSpotIndex = 2;
  final int leaderBoardIndex = 1;
  final int puzzleIndex = 0;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  Image? currentPuzzleImage;
  int? currentPuzzleNumber;
  bool _showSucessPage = false;

  //late Future<Map> futureProfile;
  //late Future<SpotRequest> currentPemit;
  final ValueNotifier<bool> _completedAllPuzzlesBool =
      SharedPrefsService().allPuzzleCompleteNotifier;
  final ValueNotifier<Spot?> _currentSpotNotifier =
      SharedPrefsService().currentSpotNotifier;
  late final ConfettiController _confettiController;
  late final AnimationController _lottieController;

  // final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(initialIndex: widget.puzzleIndex, length: 3, vsync: this);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _lottieController.addStatusListener(
      (status) {
        LoggerService.instance
            .debug("listening to success Puzzle animation $status");
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 500)).then((value) {
            setState(() {
              _lottieController.reset();
              _showSucessPage = false;
            });
            navigateBackToPuzzle();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _confettiController.dispose();
    _lottieController.dispose();
  }

  void navigateBackToPuzzle() {
    _tabController.animateTo(widget.puzzleIndex);
  }

  void navigatetoScan() {
    _tabController.animateTo(widget.scanSpotIndex);
  }

  completePuzzleCallback() async {
    LoggerService.instance.debug("Completed Puzzle!!");
    _confettiController.play();
    Spot? spot = _currentSpotNotifier.value;
    if (spot != null) {
      spot.puzzleComplete = true;
      DatabaseSpotTable.update(spot);
    }
    await DynamicAlertDialog.showDynamicDialog(
      context: context,
      icon: Icon(
        PlatformService.instance.isIos
            ? CupertinoIcons.checkmark_seal
            : Icons.verified_outlined,
        size: 40,
      ),
      title: Text(
        AppLocalizations.of(context)!.puzzleCompleteDialogTitle,
        maxLines: 3,
      ),
      content: Text(AppLocalizations.of(context)!.puzzleCompleteDialog),
      actions: [
        DynamicTextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(
              AppLocalizations.of(context)!.puzzleCompleteDialogCancelButton,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: IscteTheme.iscteColor)),
        ),
        DynamicTextButton(
          onPressed: () {
            navigatetoScan();
            Navigator.of(context).pop();
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(IscteTheme.iscteColor),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
          ),
          child: Text(
            AppLocalizations.of(context)!.puzzleCompleteDialogConfirmButton,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );

    setState(() {});
  }

  void showSuccessPage() {
    setState(() {
      _showSucessPage = true;
    });
  }

  void _completedAllPuzzles() async {
    await SharedPrefsService.storeCompletedAllPuzzles();
    navigateBackToPuzzle();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      return ValueListenableBuilder<bool>(
        valueListenable: _completedAllPuzzlesBool,
        builder: (BuildContext context, bool challengeCompleteBool, _) {
          return buildMaterialScaffold(challengeCompleteBool, orientation);
        },
      );
    });
  }

  Widget buildMaterialScaffold(
      bool challengeCompleteBool, Orientation orientation) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: MyNavigationDrawer(
          navigateBackToPuzzleCallback: navigateBackToPuzzle),
      appBar: buildAppBar(orientation, challengeCompleteBool),
      bottomNavigationBar:
          (challengeCompleteBool || orientation == Orientation.landscape)
              ? null
              : MyBottomBar(
                  tabController: _tabController,
                  initialIndex: 0,
                ),
      body: Builder(builder: (context) {
        return orientation == Orientation.landscape
            ? Row(
                children: [
                  NavigationRail(
                    backgroundColor: Colors.white,
                    selectedIconTheme: Theme.of(context).iconTheme,
                    onDestinationSelected: (index) {
                      if (index == 0) {
                        Scaffold.of(context).openDrawer();
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => FeedbackForm(),
                        );
                      }
                    },
                    selectedIndex: 0,
                    destinations: <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: const Icon(Icons.menu),
                        selectedIcon: const Icon(Icons.menu),
                        label: Text(AppLocalizations.of(context)!.menu),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.menu),
                        selectedIcon: const Icon(Icons.menu),
                        label: Text(AppLocalizations.of(context)!.menu),
                      )
                    ],
                  ),
                  const VerticalDivider(),
                  Expanded(child: buildHomeBody(challengeCompleteBool)),
                  const VerticalDivider(),
                  MyBottomBar(
                    initialIndex: 0,
                    tabController: _tabController,
                    orientation: orientation,
                  ),
                ],
              )
            : buildHomeBody(challengeCompleteBool);
      }),
    );
  }

  MyAppBar? buildAppBar(Orientation orientation, bool challengeCompleteBool) {
    return orientation == Orientation.landscape
        ? null
        : MyAppBar(
            title: AppLocalizations.of(context)!.appName,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(builder: (context) {
                  return DynamicIconButton(
                    onPressed: Scaffold.of(context).openDrawer,
                    child: const Icon(
                      Icons.menu,
                      color: IscteTheme.iscteColor,
                    ),
                  );
                }),
                if (!PlatformService.instance.isWeb) const FeedbackFormButon(),
              ],
            ),
          );
  }

  Widget buildHomeBody(bool challengeCompleteBool) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: challengeCompleteBool
          ? const CompletedChallengeWidget()
          : _showSucessPage
              ? SucessScanWidget(
                  confettiController: _confettiController,
                  lottieController: _lottieController,
                )
              : TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    buildPuzzleBody(),
                    const SafeArea(
                      child: LeaderBoardPage(hasAppBar: false),
                    ),
                    QRScanPageOpenDay(
                      navigateBackToPuzzleCallback: navigateBackToPuzzle,
                      //changeImage: changeCurrentSpot,
                      //completedAllPuzzle: _completedAllPuzzles,
                    ),
                  ],
                ),
    );
  }

  Widget buildPuzzleBody() {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return const QuizList();
            },
          )),
    );
  }
}
