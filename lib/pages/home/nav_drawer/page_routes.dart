import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/pages/home/home_page.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/pages/quiz/quiz_list_menu.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:flutter/widgets.dart';

class PageRouter {
  static Widget resolve(String route, Object? argument) {
    switch (route) {
      //case Home.pageRoute:
      //return Home();
      case HomePage.pageRoute:
        return HomePage();
      case AuthPage.pageRoute:
        return const AuthPage();
      case LeaderBoardPage.pageRoute:
        return const LeaderBoardPage();
      case QuizMenu.pageRoute:
        return const QuizMenu();
      case ProfilePage.pageRoute:
        return ProfilePage();
      case OnboardingPage.pageRoute:
        return OnboardingPage(
          onLaunch: false,
        );
      case SpotChooserPage.pageRoute:
        return SpotChooserPage();
      default:
        return HomePage();
    }
  }
}
