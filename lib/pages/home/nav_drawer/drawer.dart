import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/pages/quiz/quiz_list_menu.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:iscte_spots/services/auth/login_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyNavigationDrawer extends StatelessWidget {
  const MyNavigationDrawer({
    Key? key,
    required this.navigateBackToPuzzleCallback,
  }) : super(key: key);
  final void Function() navigateBackToPuzzleCallback;
  @override
  Widget build(BuildContext context) {
    final TextStyle? tileTextStyle = Theme.of(context).textTheme.bodyLarge;

    return Drawer(
      key: key,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("Resources/Img/Logo/logo_50_anos_main.jpg"),
                  fit: BoxFit.cover),
            ),
            child: null,
          ),
          Flexible(
            flex: 2,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                    leading: const Icon(OnboardingPage.icon),
                    title: Text(AppLocalizations.of(context)!.onboardingPage,
                        style: tileTextStyle),
                    onTap: () {
                      navigateBackToPuzzleCallback();
                      Navigator.of(context)
                          .popAndPushNamed(OnboardingPage.pageRoute);
                    }),
                ListTile(
                  leading: const Icon(SpotChooserPage.icon),
                  title: Text(AppLocalizations.of(context)!.spotChooserScreen,
                      style: tileTextStyle),
                  onTap: () {
                    navigateBackToPuzzleCallback();
                    Navigator.of(context)
                        .popAndPushNamed(SpotChooserPage.pageRoute);
                  },
                ),
                ListTile(
                  leading: const Icon(QuizMenu.icon),
                  title: Text(AppLocalizations.of(context)!.quizScreen,
                      style: tileTextStyle),
                  onTap: () {
                    //PageRoutes.animateToPage(context, page: QuizPage());
                    navigateBackToPuzzleCallback();
                    Navigator.of(context).popAndPushNamed(QuizMenu.pageRoute);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ListTile(
                    leading: const Icon(ProfilePage.icon),
                    title: Text(AppLocalizations.of(context)!.profileScreen,
                        style: tileTextStyle),
                    onTap: () {
                      navigateBackToPuzzleCallback();
                      Navigator.of(context)
                          .popAndPushNamed(ProfilePage.pageRoute);
                    }),
                ListTile(
                    leading: Icon(Icons.adaptive.arrow_back_outlined),
                    title: Text(AppLocalizations.of(context)!.logOutButton,
                        style: tileTextStyle),
                    onTap: () async {
                      navigateBackToPuzzleCallback();
                      await LoginService.logOut(context);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
