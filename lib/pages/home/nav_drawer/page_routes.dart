import 'package:flutter/widgets.dart';
import 'package:ciencia_spots/models/requests/spot_info_request.dart';
import 'package:ciencia_spots/pages/auth/auth_page.dart';
import 'package:ciencia_spots/pages/flickr/flickr_page.dart';
import 'package:ciencia_spots/pages/home/home_page.dart';
import 'package:ciencia_spots/pages/home/scanPage/timeline_study_quiz_page.dart';
import 'package:ciencia_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:ciencia_spots/pages/onboarding/onboarding_page.dart';
import 'package:ciencia_spots/pages/profile/profile_screen.dart';
import 'package:ciencia_spots/pages/quiz/quiz_list_menu.dart';
import 'package:ciencia_spots/pages/settings/settings_page.dart';
import 'package:ciencia_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:ciencia_spots/pages/timeline/details/timeline_details_page.dart';
import 'package:ciencia_spots/pages/timeline/filter/timeline_filter_results_page.dart';
import 'package:ciencia_spots/pages/timeline/timeline_page.dart';

class PageRouter {
  static Widget resolve(String route, Object? argument) {
    switch (route) {
      //case Home.pageRoute:
      //return Home();
      case HomePage.pageRoute:
        return HomePage();
      case AuthPage.pageRoute:
        return const AuthPage();
      case TimelinePage.pageRoute:
        return const TimelinePage();
      case TimeLineDetailsPage.pageRoute:
        return TimeLineDetailsPage(
          eventId: argument as int,
        );
      case TimelineFilterResultsPage.pageRoute:
        return const TimelineFilterResultsPage();
      //case Shaker.pageRoute:
      //  return Shaker();
      case FlickrPage.pageRoute:
        return FlickrPage();
      case LeaderBoardPage.pageRoute:
        return const LeaderBoardPage();
      case QuizMenu.pageRoute:
        return const QuizMenu();
      case ProfilePage.pageRoute:
        return ProfilePage();
      //case VisitedPagesPage.pageRoute:
      //  return const VisitedPagesPage();
      case SettingsPage.pageRoute:
        return const SettingsPage();
      case OnboardingPage.pageRoute:
        return OnboardingPage(
          onLaunch: false,
        );
      case TimelineStudyForQuiz.pageRoute:
        return TimelineStudyForQuiz(
          spotInfoRequest: argument as SpotInfoRequest,
        );
      case SpotChooserPage.pageRoute:
        return SpotChooserPage();
      default:
        return HomePage();
    }
  }
}

/*
class PageRoutes {
  static Route createRoute({
    required Widget widget,
    Duration transitionDuration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder(
      transitionDuration: transitionDuration,
      maintainState: true,
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Future<Widget> _buildPageAsync({required Widget page}) async {
    return Future.microtask(
      () {
        return page;
      },
    );
  }

  static Future<void> animateToPage(BuildContext context,
      {required Widget page}) async {
    Widget futurePage = await _buildPageAsync(page: page);
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRoutes.createRoute(
        widget: futurePage,
      ),
    );
  }

  static Future<void> replacePushanimateToPage(BuildContext context,
      {required Widget page}) async {
    Widget futurePage = await _buildPageAsync(page: page);
    Navigator.pushReplacement(
      context,
      PageRoutes.createRoute(
        widget: futurePage,
      ),
    );
  }
}
*/
