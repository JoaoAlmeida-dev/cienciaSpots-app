import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ciencia_spots/services/platform_service.dart';
import 'package:ciencia_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:ciencia_spots/widgets/util/iscte_theme.dart';

class AuthInitialPage extends StatelessWidget {
  const AuthInitialPage({
    Key? key,
    required this.changeToLogIn,
    required this.iscteLoginCallback,
    required this.loggingComplete,
  }) : super(key: key);
  final void Function() changeToLogIn;
  final Future<void> Function() iscteLoginCallback;

  final void Function() loggingComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 9,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.loginIscteHint,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.black),
                ),
                DynamicTextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(IscteTheme.iscteColor)),
                  onPressed: iscteLoginCallback,
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
                        "Login Iscte", //TODO
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
        Flexible(
          flex: 1,
          child: DynamicTextButton(
            style: const ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(IscteTheme.iscteColor)),
            onPressed: changeToLogIn,
            child: Text(
              "Admin Login",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
