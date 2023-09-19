import 'package:ciencia_spots/services/platform_service.dart';
import 'package:ciencia_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:ciencia_spots/widgets/util/iscte_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthInitialPage extends StatefulWidget {
  const AuthInitialPage({
    Key? key,
    required this.changeToLogIn,
    required this.changeToSignUp,
    required this.createAccountCallback,
    required this.loggingComplete,
  }) : super(key: key);
  final void Function() changeToLogIn;
  final void Function() changeToSignUp;
  final Future<void> Function() createAccountCallback;

  final void Function() loggingComplete;

  @override
  State<AuthInitialPage> createState() => _AuthInitialPageState();
}

class _AuthInitialPageState extends State<AuthInitialPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 9,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DynamicTextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(IscteTheme.iscteColor),
                    ),
                    onPressed: widget.changeToLogIn,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          PlatformService.instance.isIos
                              ? CupertinoIcons.lock
                              : Icons.lock,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Login", //TODO
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  DynamicTextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(IscteTheme.iscteColor)),
                    onPressed: widget.changeToSignUp,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          PlatformService.instance.isIos
                              ? CupertinoIcons.lock
                              : Icons.lock,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.loginRegisterButton,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  )
                ]),
          ),
          Flexible(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DynamicTextButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(IscteTheme.iscteColor)),
                  onPressed: widget.changeToLogIn,
                  child: Text(
                    AppLocalizations.of(context)!.loginAdminButton,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
