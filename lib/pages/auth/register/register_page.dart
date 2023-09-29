import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/auth/registration_form_result.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/services/auth/registration_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:lottie/lottie.dart';

import 'acount_register_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    Key? key,
    required this.changeToLogIn,
    required this.loggingComplete,
    required this.animatedSwitcherDuration,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
  final void Function() changeToLogIn;
  final void Function() loggingComplete;
  final Duration animatedSwitcherDuration;
}

class _RegisterPageState extends State<RegisterPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormState> _accountFormkey = GlobalKey<FormState>();
  bool _isLodading = false;

  RegistrationError errorCode = RegistrationError.noError;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  @override
  bool get wantKeepAlive => true;

  void _onSubmit() async {
    if (_accountFormkey.currentState!.validate()) {
      if (_accountFormkey.currentState!.validate()) {
        var registrationFormResult = RegistrationFormResult(
          username: userNameController.text,
          password: passwordController.text,
          passwordConfirmation: passwordConfirmationController.text,
        );

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

          if (_accountFormkey.currentState != null) {
            _accountFormkey.currentState!.validate();
          }
        }
        setState(() {
          _isLodading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        widget.changeToLogIn();
        return false;
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                shape: const ContinuousRectangleBorder(),
              ),
        ),
        child: AnimatedSwitcher(
          duration: widget.animatedSwitcherDuration,
          child: _isLodading
              ? const DynamicLoadingWidget()
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 8,
                        child: Theme(
                          data: ThemeData(
                            colorScheme: Theme.of(context)
                                .colorScheme
                                .copyWith(primary: IscteTheme.iscteColor),
                          ),
                          child: AccountRegisterForm(
                            errorCode: errorCode,
                            formKey: _accountFormkey,
                            userNameController: userNameController,
                            passwordController: passwordController,
                            passwordConfirmationController:
                                passwordConfirmationController,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: DynamicTextButton(
                          onPressed: _onSubmit,
                          child: Text(AppLocalizations.of(context)!
                              .createAccountButton),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Wrap(
                          direction: Axis.vertical,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          verticalDirection: VerticalDirection.down,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!
                                .loginAlreadyHaveAccount),
                            DynamicTextButton(
                              onPressed: widget.changeToLogIn,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.adaptive.arrow_back),
                                  Text(AppLocalizations.of(context)!
                                      .loginLoginButton)
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class CompleteForm extends StatelessWidget {
  const CompleteForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Lottie.network(
        'https://assets6.lottiefiles.com/packages/lf20_Vwcw5D.json',
        errorBuilder: (context, error, stackTrace) =>
            DynamicErrorWidget.networkError(
          context: context,
        ),
      ),
    );
  }
}
