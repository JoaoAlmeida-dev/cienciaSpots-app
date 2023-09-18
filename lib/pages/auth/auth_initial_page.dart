import 'package:ciencia_spots/pages/auth/register/registration_error.dart';
import 'package:ciencia_spots/services/platform_service.dart';
import 'package:ciencia_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:ciencia_spots/widgets/util/iscte_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/auth/registration_form_result.dart';
import '../../services/auth/registration_service.dart';
import '../../services/logging/LoggerService.dart';

class AuthInitialPage extends StatefulWidget {
  const AuthInitialPage({
    Key? key,
    required this.changeToLogIn,
    required this.createAccountCallback,
    required this.loggingComplete,
  }) : super(key: key);
  final void Function() changeToLogIn;
  final Future<void> Function() createAccountCallback;

  final void Function() loggingComplete;

  @override
  State<AuthInitialPage> createState() => _AuthInitialPageState();
}

class _AuthInitialPageState extends State<AuthInitialPage> {
  final TextEditingController userNameController = TextEditingController();
  bool _isLodading = false;
  RegistrationError errorCode = RegistrationError.noError;
  final GlobalKey<FormState> _accountFormkey = GlobalKey<FormState>();

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
                Form(
                    key: _accountFormkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: userNameController,
                          textAlignVertical: TextAlignVertical.top,
                          textInputAction: TextInputAction.next,
                          decoration: IscteTheme.buildInputDecoration(
                              hint: AppLocalizations.of(context)!.loginUsername,
                              errorText: (errorCode ==
                                      RegistrationError.existingUsername)
                                  ? AppLocalizations.of(context)!
                                      .registrationUsernameAlreadyExistsError
                                  : null),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .loginNoTextError;
                            }
                            return null;
                          },
                        ),
                        DynamicTextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  IscteTheme.iscteColor)),
                          onPressed: widget.createAccountCallback,
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
                                AppLocalizations.of(context)!
                                    .registrationButton, //TODO
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ]),
        ),
        Flexible(
          flex: 1,
          child: DynamicTextButton(
            style: const ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(IscteTheme.iscteColor)),
            onPressed: widget.changeToLogIn,
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

  void _onStepContinue() async {
    if (_accountFormkey.currentState!.validate()) {
      var registrationFormResult = RegistrationFormResult(
        username: userNameController.text,
      );
      /*
      var registrationFormResult = RegistrationFormResult(
        username: "test",
        firstName: "test",
        lastName: "test",
        email: "test@gmail.com",
        password: "test",
        passwordConfirmation: "test",
        affiliationType: "Alenquer",
        affiliationName: "Escola Secundária Damião de Goes",
      );
        */
      setState(() {
        _isLodading = true;
      });
      RegistrationError registrationError =
          await RegistrationService.registerNewUser(registrationFormResult);
      if (registrationError == RegistrationError.noError) {
        LoggerService.instance.info("completed registration");
        widget.loggingComplete();
      } else {
        setState(() {
          errorCode = registrationError;
        });
      }
      setState(() {
        _isLodading = false;
      });
    }
  }
}
