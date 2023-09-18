import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ciencia_spots/models/auth/login_form_result.dart';
import 'package:ciencia_spots/services/auth/login_service.dart';
import 'package:ciencia_spots/services/logging/LoggerService.dart';
import 'package:ciencia_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:ciencia_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:ciencia_spots/widgets/util/iscte_theme.dart';

bool DONTHAVEACCOUNT = false;
bool LOGINBUTTON = true;

class LoginPage extends StatefulWidget {
  LoginPage({
    Key? key,
    required this.changeToAuthInitial,
    required this.changeToSignUp,
    required this.loggingComplete,
    required this.animatedSwitcherDuration,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginOpendayState();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final void Function() loggingComplete;
  final void Function() changeToSignUp;
  final void Function() changeToAuthInitial;
  final Duration animatedSwitcherDuration;
}

class _LoginOpendayState extends State<LoginPage>
    with AutomaticKeepAliveClientMixin {
  final _loginFormkey = GlobalKey<FormState>();

  bool _hidePassword = true;
  bool _loginError = false;
  bool _generalError = false;
  bool _isLoading = false;

  bool _connectionError = false;

  String? get _errorText => _connectionError
      ? AppLocalizations.of(context)!.networkError
      : _generalError
          ? AppLocalizations.of(context)!.generalError
          : _loginError
              ? AppLocalizations.of(context)!.loginInvalidCredentials
              : null;

  String? loginValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.loginNoTextError;
    }
    return null;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedSwitcher(
      duration: widget.animatedSwitcherDuration,
      child: _isLoading
          ? const DynamicLoadingWidget()
          : Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
              child: Form(
                key: _loginFormkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 9,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (LOGINBUTTON) ...generateFormFields(),
                            generateFormButtons(),
                          ]),
                    ),
                    if (DONTHAVEACCOUNT)
                      Flexible(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!
                                .loginDontHaveAccount),
                            DynamicTextButton(
                              onPressed: widget.changeToSignUp,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.adaptive.arrow_forward),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .loginRegisterButton,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Não és um admin?"),
                          DynamicTextButton(
                            onPressed: widget.changeToAuthInitial,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.adaptive.arrow_back),
                                Text(
                                  AppLocalizations.of(context)!.back,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> generateFormFields() {
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;
    return [
      TextFormField(
        autovalidateMode: autovalidateMode,
        controller: widget.userNameController,
        textAlignVertical: TextAlignVertical.top,
        decoration: IscteTheme.buildInputDecoration(
            hint: AppLocalizations.of(context)!.loginUsername,
            errorText: _errorText),
        textInputAction: TextInputAction.next,
        validator: loginValidator,
      ),
      TextFormField(
        autovalidateMode: autovalidateMode,
        obscureText: _hidePassword,
        controller: widget.passwordController,
        textAlignVertical: TextAlignVertical.center,
        decoration: IscteTheme.buildInputDecoration(
          hint: AppLocalizations.of(context)!.loginPassword,
          errorText: _errorText,
          suffixIcon: IconButton(
            onPressed: () => setState(() => _hidePassword = !_hidePassword),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Icon(
                _hidePassword ? Icons.visibility : Icons.visibility_off,
                key: UniqueKey(),
              ),
            ),
          ),
        ),
        textInputAction: TextInputAction.done,
        validator: loginValidator,
      ),
    ];
  }

  Widget generateFormButtons() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (LOGINBUTTON)
            DynamicTextButton(
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(IscteTheme.iscteColor)),
              onPressed: _loginCallback,
              child: Text(
                AppLocalizations.of(context)!.loginScreen,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
          if (LOGINBUTTON) const SizedBox(height: 10),
        ]);
  }

  Future<void> _loginCallback() async {
    setState(() {
      _loginError = false;
      _generalError = false;
      _isLoading = true;
    });
    try {
      if (_loginFormkey.currentState!.validate()) {
        LoginFormResult loginFormResult = LoginFormResult(
          username: widget.userNameController.text,
          password: widget.passwordController.text,
        );
        int statusCode = await LoginService.login(loginFormResult);
        if (statusCode == 200) {
          widget.loggingComplete();
        } else {
          setState(() {
            _loginError = true;
          });
          LoggerService.instance.error(
              "Login error!: statusCode: $statusCode; loginForm: $loginFormResult;");
        }
      }
    } on SocketException catch (e) {
      setState(() {
        _connectionError = true;
      });
      LoggerService.instance.error(e);
      LoggerService.instance.error("SocketException on login!");
    } catch (e) {
      setState(() {
        _generalError = true;
      });
      LoggerService.instance.error(e);
    }

    setState(() {
      _isLoading = false;
    });
  }
}
