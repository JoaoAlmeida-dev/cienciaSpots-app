import 'package:ciencia_spots/models/timeline/feedback_form_result.dart';
import 'package:ciencia_spots/services/timeline/feedback_service.dart';
import 'package:ciencia_spots/widgets/dynamic_widgets/dynamic_icon_button.dart';
import 'package:ciencia_spots/widgets/dynamic_widgets/dynamic_snackbar.dart';
import 'package:ciencia_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:ciencia_spots/widgets/util/iscte_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeedbackFormButon extends StatelessWidget {
  const FeedbackFormButon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicIconButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => FeedbackForm(),
      ),
      child: const Icon(
        //Icons.feedback_outlined,
        CupertinoIcons.exclamationmark_bubble,
        color: IscteTheme.iscteColor,
      ),
    );
  }
}

class FeedbackForm extends StatefulWidget {
  FeedbackForm({Key? key}) : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final GlobalKey<FormState> _feedbackFormKey = GlobalKey<FormState>();
  TextEditingController descriptionFieldController = TextEditingController();
  TextEditingController nameFieldController = TextEditingController();
  TextEditingController emailFieldController = TextEditingController();

  AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;

  void submitForm() async {
    if (_feedbackFormKey.currentState?.validate() ?? false) {
      final feedbackresult = FeedbackFormResult(
        email: emailFieldController.text,
        name: nameFieldController.text,
        description: descriptionFieldController.text,
      );
      bool sendFeedbackSuccess = await FeedbackService.sendFeedback(
          feedbackFormResult: feedbackresult);

      if (!mounted) return;
      Navigator.of(context).pop();
      DynamicSnackBar.showSnackBar(
        context,
        sendFeedbackSuccess
            ? Text(
                AppLocalizations.of(context)!.feedbackFormSubmissionSuccess,
                style: const TextStyle(color: IscteTheme.iscteColor),
              )
            : Text(
                AppLocalizations.of(context)!.feedbackFormSubmissionError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
        const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var base = Theme.of(context).textTheme.titleLarge;
    var textstyle = base?.copyWith(color: IscteTheme.iscteColor);
    const SizedBox formSpacer = SizedBox(height: 16.0);

    return AlertDialog(
      scrollable: true,
      titlePadding: EdgeInsets.all(10),
      contentPadding: EdgeInsets.all(10),
      actionsPadding: EdgeInsets.all(10),
      contentTextStyle: textstyle,
      title: Text(AppLocalizations.of(context)!.feedbackFormTitle),
      actions: [
        DynamicTextButton(
          onPressed: submitForm,
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(IscteTheme.iscteColor)),
          child: Text(
            AppLocalizations.of(context)!.feedbackFormSubmit,
            style: textstyle,
          ),
        ),
        DynamicTextButton(
          onPressed: Navigator.of(context).pop,
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(IscteTheme.iscteColor)),
          child: Text(
            AppLocalizations.of(context)!.feedbackFormCancel,
            style: base,
          ),
        )
      ],
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.right,
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Form(
                key: _feedbackFormKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      textAlignVertical: TextAlignVertical.top,
                      textAlign: TextAlign.start,
                      autofocus: true,
                      style: base,
                      autovalidateMode: autovalidateMode,
                      controller: nameFieldController,
                      textInputAction: TextInputAction.next,
                      cursorColor: IscteTheme.iscteColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              ?.feedbackFormValidation;
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          labelStyle: textstyle,
                          labelText: AppLocalizations.of(context)
                              ?.feedbackFormNameField),
                    ),
                    formSpacer,
                    TextFormField(
                      textAlignVertical: TextAlignVertical.top,
                      textAlign: TextAlign.start,
                      style: base,
                      autovalidateMode: autovalidateMode,
                      cursorColor: IscteTheme.iscteColor,
                      textInputAction: TextInputAction.next,
                      controller: emailFieldController,
                      decoration: InputDecoration(
                          labelStyle: textstyle,
                          labelText: AppLocalizations.of(context)
                              ?.feedbackFormEmailField),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              ?.feedbackFormValidation;
                          //} else if (!RegExp(r"\S+[@]\S+\.\S+").hasMatch(value)) {
                          //https://regex101.com/r/TZDJmb/1
                        } else if (!RegExp(
                                r"(([_A-Za-z0-9-]+)(\.[_A-Za-z0-9-]+)*|[\[\{\(]([_A-Za-z0-9-,;\/\|\s?]+)(\.[_A-Za-z0-9-,;\/\|\s?]+)*[\}\]\)])\s*@\s*[_A-Za-z0-9-]+(\.[_A-Za-z0-9-]+)*(\.[A-Za-z]{2,})")
                            .hasMatch(value)) {
                          //RegExp Explanation (checks for @ followed by any number of non whitespace character followed by a dot "." and then followed by any number of non whitespace characters)
                          //https://regex101.com/r/pYrcfO/1
                          return AppLocalizations.of(context)
                              ?.feedbackFormEmailValidation;
                        }
                        return null;
                      },
                    ),
                    formSpacer,
                    TextFormField(
                      textAlignVertical: TextAlignVertical.top,
                      textAlign: TextAlign.start,
                      maxLines: 5,
                      style: base,
                      textInputAction: TextInputAction.newline,
                      autovalidateMode: autovalidateMode,
                      controller: descriptionFieldController,
                      cursorColor: IscteTheme.iscteColor,
                      decoration: InputDecoration(
                          labelStyle: textstyle,
                          labelText: AppLocalizations.of(context)
                              ?.feedbackFormDescriptionField),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              ?.feedbackFormValidation;
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
