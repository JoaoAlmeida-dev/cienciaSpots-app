import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/nav_drawer/drawer.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';
import 'package:iscte_spots/pages/home/scanPage/openday_qr_scan_page.dart';
import 'package:iscte_spots/pages/home/state/puzzle_state.dart';
import 'package:iscte_spots/pages/home/widgets/sucess_scan_widget.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:iscte_spots/pages/timeline/feedback_form.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/puzzle_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_icon_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_progress_indicator.dart';
import 'package:iscte_spots/widgets/iscte_confetti_widget.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';

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
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () => PuzzleService.PuzzleCompletePost(
      //         context: context,
      //         confettiController: _confettiController,
      //         spot: _currentSpotNotifier.value,
      //         navigatetoScan: navigatetoScan,
      //         navigatetoPuzzle: navigateBackToPuzzle),
      //     child: const FaIcon(FontAwesomeIcons.puzzlePiece)),
      body: Builder(builder: (context) {
        return orientation == Orientation.landscape
            ? Row(
                children: [
                  ValueListenableBuilder<Spot?>(
                      valueListenable: _currentSpotNotifier,
                      builder: (context, currentSpot, _) {
                        return NavigationRail(
                          backgroundColor: Colors.white,
                          selectedIconTheme: Theme.of(context).iconTheme,
                          onDestinationSelected: (index) {
                            if (index == 0) {
                              Scaffold.of(context).openDrawer();
                            } else {
                              if (currentSpot?.photoLink != null) {
                                String imgLink = currentSpot!.photoLink;
                                showHelpOverlay(
                                  context,
                                  Image.network(imgLink),
                                  orientation,
                                );
                              }
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
                              icon: const Icon(Icons.question_mark),
                              label: Text(AppLocalizations.of(context)!.help),
                            ),
                          ],
                        );
                      }),
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
            trailing: challengeCompleteBool
                ? null
                : ValueListenableBuilder<Spot?>(
                    valueListenable: _currentSpotNotifier,
                    builder: (context, value, _) {
                      if (value?.photoLink != null) {
                        String imgLink = value!.photoLink;
                        return DynamicIconButton(
                          child: PlatformService.instance.isIos
                              ? const Icon(
                                  CupertinoIcons.question,
                                  color: IscteTheme.iscteColor,
                                )
                              : const Icon(Icons.question_mark),
                          onPressed: () => showHelpOverlay(
                              context, Image.network(imgLink), orientation),
                        );
                      } else {
                        return Container();
                      }
                    },
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
                    ),
                  ],
                ),
    );
  }

  Widget buildPuzzleBody() {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ValueListenableBuilder<Spot?>(
              valueListenable: _currentSpotNotifier,
              builder: (context, currentSpot, _) {
                if (currentSpot != null) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return PuzzlePage(
                                  spot: currentSpot,
                                  completeCallback: () =>
                                      PuzzleService.PuzzleCompletePost(
                                    context: context,
                                    confettiController: _confettiController,
                                    spot: _currentSpotNotifier.value,
                                    navigatetoScan: navigatetoScan,
                                    navigatetoPuzzle: navigateBackToPuzzle,
                                  ),
                                  constraints: constraints,
                                );
                              },
                            ),
                            IscteConfetti(
                                confettiController: _confettiController),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<double>(
                          valueListenable: PuzzleState.currentPuzzleProgress,
                          builder: (context, double progress, _) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.puzzleProgress(
                                    (progress * 100).round(),
                                    currentSpot.description,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: IscteTheme.iscteColor,
                                      ),
                                ),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: progress,
                                  ),
                                  builder: (context, value, _) =>
                                      DynamicProgressIndicator(
                                    value: value,
                                    color: IscteTheme.iscteColor,
                                    backgroundColor: IscteTheme.greyColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }),
                    ],
                  );
                } else {
                  return Center(
                    child: InkWell(
                      onTap: () => Navigator.of(context)
                          .pushNamed(SpotChooserPage.pageRoute),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              SpotChooserPage.icon,
                              size: 100,
                            ),
                            Text(
                              AppLocalizations.of(context)!.spotChooserScreen,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: IscteTheme.iscteColor,
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              })),
    );
  }
}
