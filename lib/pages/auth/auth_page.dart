import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/auth/login/login_page.dart';
import 'package:iscte_spots/pages/auth/register/register_page.dart';
import 'package:iscte_spots/pages/home/home_page.dart';
import 'package:iscte_spots/services/auth/login_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:lottie/lottie.dart';

class AuthPage extends StatefulWidget {
  static const pageRoute = "/auth";

  AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool _isLoggedIn = true;
  bool _isLoading = true;
  late List<StatefulWidget> _pages;
  final int _loginIndex = 0;
  final int _registerIndex = 1;
  late TabController _tabController;
  late final AnimationController _lottieController;
  final animatedSwitcherDuration = const Duration(seconds: 1);

  @override
  void dispose() {
    _tabController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      LoginPage(
        changeToSignUp: changeToSignUp,
        loggingComplete: loggingComplete,
        animatedSwitcherDuration: animatedSwitcherDuration,
      ),
      RegisterPage(
        changeToLogIn: changeToLogIn,
        loggingComplete: loggingComplete,
        animatedSwitcherDuration: animatedSwitcherDuration,
      ),
    ];
    _tabController = TabController(length: _pages.length, vsync: this);
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _lottieController.addStatusListener(
      (status) {
        LoggerService.instance
            .debug("listenning to complete login animation $status");
        if (status == AnimationStatus.completed) {
          Future.delayed(
            const Duration(milliseconds: 500),
          ).then(
            (value) =>
                Navigator.pushReplacementNamed(context, HomePage.pageRoute),
          );
        }
      },
    );

    initFunc();
  }

  void initFunc() async {
    bool loggedIn;
    try {
      loggedIn = await LoginService.isLoggedIn();
    } on SocketException {
      loggedIn = false;
    }
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
    if (_isLoggedIn) {
      loggingComplete();
    }
  }

  void loggingComplete() async {
    setState(() => _isLoggedIn = true);
  }

  void changeToSignUp() {
    _tabController.animateTo(_registerIndex);
  }

  void changeToLogIn() {
    _tabController.animateTo(_loginIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedSwitcher(
        duration: animatedSwitcherDuration,
        child: _isLoading
            ? const DynamicLoadingWidget()
            : _isLoggedIn
                ? lottieCompleteLoginBuilder()
                : TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: _pages,
                  ),
      ),
    );
  }

  Widget lottieCompleteLoginBuilder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.network(
            "https://assets6.lottiefiles.com/packages/lf20_Vwcw5D.json",
            //width: MediaQuery.of(context).size.width * 0.5,
            //height: MediaQuery.of(context).size.height * 0.5,
            //fit: BoxFit.contain,
            controller: _lottieController,
            onLoaded: (LottieComposition composition) {
              TickerFuture forward = _lottieController.forward();
            },
          )
        ],
      );
}
