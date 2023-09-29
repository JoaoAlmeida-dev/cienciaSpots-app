import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/pages/quiz/quiz_list_menu.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:iscte_spots/services/auth/login_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';

import '../../../widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import '../../../widgets/util/iscte_theme.dart';

class MyNavigationDrawer extends StatelessWidget {
  const MyNavigationDrawer({
    Key? key,
    required this.navigateBackToPuzzleCallback,
  }) : super(key: key);
  final void Function() navigateBackToPuzzleCallback;

  @override
  Widget build(BuildContext context) {
    final TextStyle? tileTextStyle = Theme.of(context).textTheme.bodyLarge;

    return SafeArea(
      child: Drawer(
        key: key,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            //const SizedBox(height:10),
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image:
                        AssetImage("Resources/Img/Nei/nei_principal_logo.png"),
                    fit: BoxFit.contain),
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
                  ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: Text(
                          AppLocalizations.of(context)!.deleteAccountButton,
                          style: tileTextStyle?.copyWith(color: Colors.red)),
                      onTap: () async {
                        await DynamicAlertDialog.showDynamicDialog(
                            context: context,
                            icon: const Icon(
                              Icons.warning,
                              color: Colors.red,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.deleteAccountButton,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.red),
                            ),
                            content: Text(AppLocalizations.of(context)!
                                .deleteAccountWarningText),
                            actions: [
                              DynamicTextButton(
                                onPressed: () async =>
                                    Navigator.of(context).pop(),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      IscteTheme.iscteColor),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .feedbackFormCancel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                              DynamicTextButton(
                                child: Text(
                                    AppLocalizations.of(context)!.confirm,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            color: IscteTheme.iscteColor)),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  DynamicAlertDialog.showDynamicDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      content: SizedBox.fromSize(
                                          size:
                                              MediaQuery.of(context).size * 0.3,
                                          child: const DynamicLoadingWidget()));
                                  navigateBackToPuzzleCallback();
                                  await LoginService.deleteAccount(context);
                                },
                              ),
                            ]);
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
